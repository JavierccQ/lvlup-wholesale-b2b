// ============================================================================
//  lvlupCatalogPulseCarousel  →  carrusel de "Novedades de catálogo" para el buyer
// ============================================================================
//  Muestra las novedades (nuevos productos, reposiciones, actualizaciones) que
//  son RELEVANTES y VISIBLES para el comprador que ha iniciado sesión. Los datos
//  vienen de un Apex cacheable (LvlupCatalogPulseController) que consulta el feed
//  persistido Catalog_Pulse_Item__c: el componente NO escucha eventos efímeros
//  del bus, consulta datos ya materializados (arquitectura event-driven backend).
//
//  Estados: loading / error / empty / con datos. Mobile-first (scroll-snap) y
//  accesible (roles, aria, navegación por teclado en los botones).
// ============================================================================
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getCatalogPulseForBuyer from "@salesforce/apex/LvlupCatalogPulseController.getCatalogPulseForBuyer";

const DEFAULT_MAX_ITEMS = 12;
// Misma convención de imágenes que el resto del storefront (REGLA-013): si el
// controller no resolvió una URL, se arma un fallback por SKU desde el repo.
const IMAGE_BASE_URL =
  "https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images";

export default class LvlupCatalogPulseCarousel extends NavigationMixin(
  LightningElement
) {
  // Título configurable en el Experience Builder.
  @api cardTitle = "Novedades para ti";
  // Máximo de novedades a pedir (el Apex lo re-normaliza y topa a 24).
  @api maxItems = DEFAULT_MAX_ITEMS;
  // Si está activo, cuando no hay novedades el componente no ocupa espacio.
  @api hideWhenEmpty = false;

  items = [];
  isLoading = true;
  hasError = false;

  @wire(getCatalogPulseForBuyer, { maxItems: "$maxItems" })
  wiredPulse({ data, error }) {
    if (data) {
      this.items = this.decorate(data);
      this.isLoading = false;
      this.hasError = false;
    } else if (error) {
      this.items = [];
      this.isLoading = false;
      this.hasError = true;
    }
  }

  // Enriquecemos cada fila con datos de presentación (imagen resuelta + clase del badge).
  decorate(rows) {
    return rows.map((row) => ({
      ...row,
      imageSrc: this.resolveImage(row),
      badgeClass: this.badgeClass(row.changeType)
    }));
  }

  resolveImage(row) {
    if (row.imageUrl) {
      return row.imageUrl;
    }
    if (row.sku) {
      return `${IMAGE_BASE_URL}/${row.sku}.png`;
    }
    return null;
  }

  badgeClass(changeType) {
    const base = "pulse-badge";
    switch (changeType) {
      case "NEW":
        return `${base} pulse-badge_new`;
      case "RESTOCK":
        return `${base} pulse-badge_restock`;
      case "PRICE_DROP":
        return `${base} pulse-badge_price`;
      default:
        return `${base} pulse-badge_updated`;
    }
  }

  get hasItems() {
    return this.items && this.items.length > 0;
  }

  get showEmpty() {
    return (
      !this.isLoading && !this.hasError && !this.hasItems && !this.hideWhenEmpty
    );
  }

  get showCarousel() {
    return !this.isLoading && !this.hasError && this.hasItems;
  }

  // Clic/teclado sobre una tarjeta → navegar a la ficha del producto (PDP).
  handleOpenProduct(event) {
    const productId = event.currentTarget.dataset.productId;
    if (!productId) {
      return;
    }
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: productId,
        objectApiName: "Product2",
        actionName: "view"
      }
    });
  }

  // Si una imagen no carga, la ocultamos y dejamos el placeholder del CSS.
  handleImageError(event) {
    event.target.classList.add("is-hidden");
  }

  handlePrev() {
    this.scrollByAmount(-1);
  }

  handleNext() {
    this.scrollByAmount(1);
  }

  scrollByAmount(direction) {
    const track = this.template.querySelector(".pulse-track");
    if (track) {
      track.scrollBy({
        left: direction * track.clientWidth * 0.85,
        behavior: "smooth"
      });
    }
  }
}
