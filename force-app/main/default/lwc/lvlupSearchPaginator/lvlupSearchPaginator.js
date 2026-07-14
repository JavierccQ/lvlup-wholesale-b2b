// ============================================================================
//  lvlupSearchPaginator → custom paginator for the search/category results grid
// ============================================================================
//  Why it exists: the category PLP renders products with the dxp Grid bound to
//  {!Search.Results.cardCollection} (custom per-card layout). The Grid's own
//  paginator can't page that source (a static expression list with no paging
//  metadata), so buyers were capped at the first search page.
//
//  How it works: pagination state of the commerce search data provider lives in
//  the URL (?page=N). This component navigates to the same route with the
//  target page in the query string; the data provider re-queries and the Grid
//  re-renders with the new page. Only public APIs (lightning/navigation).
// ============================================================================
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

const DEFAULT_PAGE_SIZE = 20;

export default class LvlupSearchPaginator extends NavigationMixin(
  LightningElement
) {
  // Builder-bound expressions (type them manually in the property panel):
  @api currentPage; // {!Search.Pagination.currentPage} (fallback; URL wins)
  @api loadedCount; // {!Search.Results.productLoadedCount}
  @api resultsDescription; // {!Search.Results.description}, e.g. "83 Items"

  // Design-time settings:
  @api pageSize = DEFAULT_PAGE_SIZE;
  @api previousLabel = "Anterior";
  @api nextLabel = "Siguiente";
  @api maxPageButtons = 5;

  pageRef;

  @wire(CurrentPageReference)
  wiredPageRef(ref) {
    this.pageRef = ref;
  }

  // The URL (?page=N) is the source of truth; the bound expression is a fallback.
  get page() {
    const fromUrl = parseInt(this.pageRef?.state?.page, 10);
    if (fromUrl >= 1) {
      return fromUrl;
    }
    const fromBinding = parseInt(this.currentPage, 10);
    return fromBinding >= 1 ? fromBinding : 1;
  }

  // Total item count parsed from the results description ("83 Items").
  get totalCount() {
    const match = /([\d.,]*\d)/.exec(this.resultsDescription || "");
    if (!match) {
      return null;
    }
    const count = parseInt(match[1].replace(/[.,]/g, ""), 10);
    return Number.isNaN(count) ? null : count;
  }

  get effectivePageSize() {
    const size = parseInt(this.pageSize, 10);
    return size >= 1 ? size : DEFAULT_PAGE_SIZE;
  }

  get totalPages() {
    if (this.totalCount !== null) {
      return Math.max(1, Math.ceil(this.totalCount / this.effectivePageSize));
    }
    // Unknown total: if the current page came back full, assume one more page.
    const loaded = parseInt(this.loadedCount, 10);
    return loaded === this.effectivePageSize ? this.page + 1 : this.page;
  }

  get showPaginator() {
    return this.totalPages > 1;
  }

  get isFirstPage() {
    return this.page <= 1;
  }

  get isLastPage() {
    return this.page >= this.totalPages;
  }

  // Sliding window of numbered buttons centered on the current page.
  get pageItems() {
    const max = parseInt(this.maxPageButtons, 10) || 5;
    const total = this.totalPages;
    let start = Math.max(1, this.page - Math.floor(max / 2));
    const end = Math.min(total, start + max - 1);
    start = Math.max(1, end - max + 1);
    const items = [];
    for (let n = start; n <= end; n++) {
      const isCurrent = n === this.page;
      items.push({
        number: n,
        cssClass: isCurrent ? "page-btn active" : "page-btn",
        ariaCurrent: isCurrent ? "page" : null
      });
    }
    return items;
  }

  handlePrevious() {
    this.goToPage(this.page - 1);
  }

  handleNext() {
    this.goToPage(this.page + 1);
  }

  handlePageClick(event) {
    this.goToPage(parseInt(event.currentTarget.dataset.page, 10));
  }

  goToPage(target) {
    if (!this.pageRef || target === this.page || target < 1) {
      return;
    }
    const state = { ...(this.pageRef.state || {}) };
    if (target <= 1) {
      delete state.page; // page 1 = clean URL, same as the provider default
    } else {
      state.page = String(target);
    }
    this[NavigationMixin.Navigate]({
      type: this.pageRef.type,
      attributes: { ...this.pageRef.attributes },
      state
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
}
