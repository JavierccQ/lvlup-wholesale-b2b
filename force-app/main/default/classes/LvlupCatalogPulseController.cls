/**
 * ============================================================================
 *  LvlupCatalogPulseController  (back-end del carrusel lvlupCatalogPulseCarousel)
 * ============================================================================
 *  Devuelve al storefront las novedades de catálogo (Catalog_Pulse_Item__c)
 *  RELEVANTES y VISIBLES para el comprador que hace la petición.
 *
 *  ── SEGURIDAD: EL ENTITLEMENT ES LA FRONTERA, NO EL UI (REGLA-003/004, ADR-0004)
 *  Nunca se devuelve un producto que el buyer no esté entitled a ver, aunque
 *  exista un Catalog_Pulse_Item__c para él. El filtro real es el join contra
 *  CommerceEntitlementProduct de las políticas de los Buyer Groups del comprador.
 *  El `Segment_Key__c` es solo un filtro funcional adicional (afinado por grupo);
 *  la visibilidad la manda el entitlement.
 *
 *  ── SHARING ─────────────────────────────────────────────────────────────────
 *  `without sharing` a propósito: en B2B Commerce los registros de catálogo no se
 *  comparten al comprador por sharing (la visibilidad la da el entitlement). Con
 *  `with sharing` la consulta devolvería 0 filas. Resolvemos la visibilidad en
 *  código con el join de entitlement, que es la fuente de verdad. El acceso a la
 *  CLASE se concede al buyer vía el permission set LvlUp_Catalog_Pulse_Buyer.
 * ============================================================================
 */
public without sharing class LvlupCatalogPulseController {
  private static final Integer DEFAULT_MAX_ITEMS = 12;
  private static final Integer HARD_MAX_ITEMS = 24;
  private static final String STATUS_ACTIVE = 'ACTIVE';
  private static final String SOURCE_PLATZI = 'Platzi';
  private static final String STATUS_PUBLISHED = 'Published';

  /**
   * Punto de entrada del LWC. Resuelve el contexto del comprador (cuenta ->
   * Buyer Groups -> políticas -> productos entitled -> segmentos) y devuelve las
   * novedades activas, vigentes y visibles.
   *
   * @param maxItems tope de items (se normaliza entre 1 y HARD_MAX_ITEMS).
   * @return lista de vistas listas para pintar; vacía si no hay contexto de buyer.
   */
  @AuraEnabled(cacheable=true)
  public static List<PulseItemView> getCatalogPulseForBuyer(Integer maxItems) {
    Integer limitSize = normaliseLimit(maxItems);
    BuyerContext ctx = resolveBuyerContext();
    if (ctx == null || ctx.entitledProductIds.isEmpty()) {
      return new List<PulseItemView>();
    }
    return queryPulse(ctx.entitledProductIds, ctx.segmentKeys, limitSize);
  }

  /**
   * Núcleo testeable: dada la visibilidad ya resuelta (productos entitled) y los
   * segmentos del buyer, consulta el feed vigente y lo mapea a vistas. Se testea
   * directamente con datos, sin depender de un usuario de comunidad.
   */
  @TestVisible
  private static List<PulseItemView> queryPulse(
    Set<Id> entitledProductIds,
    Set<String> segmentKeys,
    Integer limitSize
  ) {
    List<PulseItemView> views = new List<PulseItemView>();
    if (entitledProductIds == null || entitledProductIds.isEmpty()) {
      return views;
    }
    Set<String> segments = segmentKeys == null
      ? new Set<String>()
      : segmentKeys;
    Datetime now = System.now();
    List<Catalog_Pulse_Item__c> rows = [
      SELECT
        Id,
        Product__c,
        Product__r.Name,
        Product__r.StockKeepingUnit,
        Product__r.DisplayUrl,
        Product_Code__c,
        Change_Type__c,
        Title__c,
        Message__c,
        Priority__c,
        Effective_Date__c,
        Segment_Key__c
      FROM Catalog_Pulse_Item__c
      WHERE
        Status__c = :STATUS_ACTIVE
        AND Product__c IN :entitledProductIds
        AND Effective_Date__c <= :now
        AND (Expiration_Date__c = NULL
        OR Expiration_Date__c > :now)
        AND (Segment_Key__c = NULL
        OR Segment_Key__c IN :segments)
      ORDER BY Effective_Date__c DESC
      LIMIT :limitSize
    ];
    if (rows.isEmpty()) {
      return views;
    }
    Map<String, String> externalImageBySku = resolveExternalImages(rows);
    for (Catalog_Pulse_Item__c row : rows) {
      views.add(toView(row, externalImageBySku));
    }
    return views;
  }

  // ── Resolución del contexto del comprador ──────────────────────────────────

  private static BuyerContext resolveBuyerContext() {
    Id accountId = resolveBuyerAccountId();
    if (accountId == null) {
      return null;
    }
    return resolveBuyerContext(accountId);
  }

  /**
   * Resuelve, para una cuenta buyer, sus segmentos (nombres de Buyer Group) y el
   * conjunto de productos entitled a través de las políticas de sus grupos.
   * @TestVisible para poder cubrir la cadena grupo -> política -> entitlement.
   */
  @TestVisible
  private static BuyerContext resolveBuyerContext(Id accountId) {
    Set<Id> groupIds = new Set<Id>();
    Set<String> segmentKeys = new Set<String>();
    for (BuyerGroupMember member : [
      SELECT BuyerGroupId, BuyerGroup.Name
      FROM BuyerGroupMember
      WHERE BuyerId = :accountId
    ]) {
      groupIds.add(member.BuyerGroupId);
      if (member.BuyerGroup.Name != null) {
        segmentKeys.add(member.BuyerGroup.Name);
      }
    }
    if (groupIds.isEmpty()) {
      return null;
    }
    Set<Id> policyIds = new Set<Id>();
    for (CommerceEntitlementBuyerGroup ebg : [
      SELECT PolicyId
      FROM CommerceEntitlementBuyerGroup
      WHERE BuyerGroupId IN :groupIds
    ]) {
      policyIds.add(ebg.PolicyId);
    }
    Set<Id> entitledProductIds = new Set<Id>();
    if (!policyIds.isEmpty()) {
      for (CommerceEntitlementProduct ep : [
        SELECT ProductId
        FROM CommerceEntitlementProduct
        WHERE PolicyId IN :policyIds
      ]) {
        entitledProductIds.add(ep.ProductId);
      }
    }
    BuyerContext ctx = new BuyerContext();
    ctx.accountId = accountId;
    ctx.segmentKeys = segmentKeys;
    ctx.entitledProductIds = entitledProductIds;
    return ctx;
  }

  /** Cuenta del comprador que ejecuta (a través de su Contact). Null si no aplica. */
  private static Id resolveBuyerAccountId() {
    User runningUser = [
      SELECT ContactId, Contact.AccountId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    return runningUser.ContactId != null ? runningUser.Contact.AccountId : null;
  }

  // ── Imágenes y mapeo a vista ───────────────────────────────────────────────

  /**
   * Para los productos cuyo DisplayUrl viene vacío (típico de productos externos
   * Platzi), resuelve la URL real de imagen desde el staging External_Product__c,
   * reutilizando el mismo casado por SKU que usa el resto del storefront (REGLA-013).
   */
  private static Map<String, String> resolveExternalImages(
    List<Catalog_Pulse_Item__c> rows
  ) {
    Map<String, String> urlsBySku = new Map<String, String>();
    Set<String> skus = new Set<String>();
    for (Catalog_Pulse_Item__c row : rows) {
      if (
        row.Product__r != null &&
        String.isNotBlank(row.Product__r.StockKeepingUnit) &&
        String.isBlank(row.Product__r.DisplayUrl)
      ) {
        skus.add(row.Product__r.StockKeepingUnit);
      }
    }
    if (skus.isEmpty()) {
      return urlsBySku;
    }
    for (External_Product__c ext : [
      SELECT Salesforce_Product__r.StockKeepingUnit, External_Image_URL__c
      FROM External_Product__c
      WHERE
        Sync_Status__c = :STATUS_PUBLISHED
        AND External_Source__c = :SOURCE_PLATZI
        AND External_Image_URL__c != NULL
        AND Salesforce_Product__r.StockKeepingUnit IN :skus
    ]) {
      urlsBySku.put(
        ext.Salesforce_Product__r.StockKeepingUnit,
        ext.External_Image_URL__c
      );
    }
    return urlsBySku;
  }

  private static PulseItemView toView(
    Catalog_Pulse_Item__c row,
    Map<String, String> externalImageBySku
  ) {
    PulseItemView view = new PulseItemView();
    view.id = row.Id;
    view.productId = row.Product__c;
    view.productName = row.Product__r != null ? row.Product__r.Name : null;
    view.sku = row.Product__r != null &&
      row.Product__r.StockKeepingUnit != null
      ? row.Product__r.StockKeepingUnit
      : row.Product_Code__c;
    view.imageUrl = resolveImageUrl(row, externalImageBySku);
    view.changeType = row.Change_Type__c;
    view.changeTypeLabel = labelFor(row.Change_Type__c);
    view.title = row.Title__c;
    view.message = row.Message__c;
    view.priority = row.Priority__c;
    view.effectiveDate = row.Effective_Date__c;
    return view;
  }

  private static String resolveImageUrl(
    Catalog_Pulse_Item__c row,
    Map<String, String> externalImageBySku
  ) {
    if (
      row.Product__r != null && String.isNotBlank(row.Product__r.DisplayUrl)
    ) {
      return row.Product__r.DisplayUrl;
    }
    String sku = row.Product__r != null
      ? row.Product__r.StockKeepingUnit
      : null;
    if (sku != null && externalImageBySku.containsKey(sku)) {
      return externalImageBySku.get(sku);
    }
    return null; // el LWC aplica su fallback por SKU si no hay URL.
  }

  private static String labelFor(String changeType) {
    if (changeType == 'NEW') {
      return 'Nuevo';
    }
    if (changeType == 'PRICE_DROP') {
      return 'Bajada de precio';
    }
    if (changeType == 'RESTOCK') {
      return 'De nuevo en stock';
    }
    if (changeType == 'UPDATED') {
      return 'Actualizado';
    }
    return changeType;
  }

  private static Integer normaliseLimit(Integer maxItems) {
    if (maxItems == null || maxItems <= 0) {
      return DEFAULT_MAX_ITEMS;
    }
    return maxItems > HARD_MAX_ITEMS ? HARD_MAX_ITEMS : maxItems;
  }

  /** Contexto de visibilidad del comprador resuelto server-side. */
  public class BuyerContext {
    public Id accountId;
    public Set<String> segmentKeys = new Set<String>();
    public Set<Id> entitledProductIds = new Set<Id>();
  }

  /** DTO que viaja al LWC. Cada campo lleva @AuraEnabled para ser visible en JS. */
  public class PulseItemView {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public String changeType;
    @AuraEnabled
    public String changeTypeLabel;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public String priority;
    @AuraEnabled
    public Datetime effectiveDate;
  }
}
