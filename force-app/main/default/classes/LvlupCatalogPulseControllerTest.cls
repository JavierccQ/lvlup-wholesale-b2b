/**
 * ============================================================================
 *  LvlupCatalogPulseControllerTest
 * ============================================================================
 *  Verifica el núcleo entitlement-aware queryPulse: que solo devuelve novedades
 *  ACTIVAS, vigentes, del segmento del buyer y —sobre todo— de productos que el
 *  buyer está entitled a ver; y que resuelve imagen/label. También cubre el
 *  camino sin contexto de comprador (admin) y una cuenta sin Buyer Group.
 *
 *  La cadena real cuenta -> Buyer Group -> política -> entitlement se valida como
 *  Buyer real en el storefront (REGLA-001, datos de Commerce = ADR-0003), no aquí.
 * ============================================================================
 */
@isTest
private class LvlupCatalogPulseControllerTest {
  @TestSetup
  static void setup() {
    List<Product2> products = new List<Product2>{
      new Product2(
        Name = 'Pulse P1',
        ProductCode = 'LVL-PUL-001',
        StockKeepingUnit = 'LVL-PUL-001',
        IsActive = true,
        DisplayUrl = 'https://example.com/lvl-pul-001.png'
      ),
      new Product2(
        Name = 'Pulse P2',
        ProductCode = 'LVL-PUL-002',
        StockKeepingUnit = 'LVL-PUL-002',
        IsActive = true
      )
    };
    insert products;
  }

  private static Map<String, Id> productIdsByCode() {
    Map<String, Id> byCode = new Map<String, Id>();
    for (Product2 p : [
      SELECT Id, ProductCode
      FROM Product2
      WHERE ProductCode LIKE 'LVL-PUL-%'
    ]) {
      byCode.put(p.ProductCode, p.Id);
    }
    return byCode;
  }

  private static Catalog_Pulse_Item__c item(
    Id productId,
    String key,
    String segment,
    Datetime effective,
    Datetime expiration,
    String status
  ) {
    return new Catalog_Pulse_Item__c(
      Pulse_Key__c = key,
      Product__c = productId,
      Product_Code__c = 'LVL-PUL',
      Change_Type__c = 'NEW',
      Segment_Key__c = segment,
      Title__c = 'Novedad',
      Message__c = 'Mensaje',
      Priority__c = 'HIGH',
      Effective_Date__c = effective,
      Expiration_Date__c = expiration,
      Status__c = status
    );
  }

  @isTest
  static void returnsActiveEntitledItemsWithImageAndLabel() {
    Map<String, Id> ids = productIdsByCode();
    Id p1 = ids.get('LVL-PUL-001');
    insert item(
      p1,
      p1 + '|NEW|GLOBAL',
      null,
      System.now().addHours(-1),
      System.now().addDays(10),
      'ACTIVE'
    );

    Test.startTest();
    List<LvlupCatalogPulseController.PulseItemView> views = LvlupCatalogPulseController.queryPulse(
      new Set<Id>{ p1 },
      new Set<String>(),
      12
    );
    Test.stopTest();

    System.assertEquals(
      1,
      views.size(),
      'Una novedad activa, vigente y entitled'
    );
    System.assertEquals(
      p1,
      views[0].productId,
      'Debe ser el producto entitled'
    );
    System.assertEquals(
      'Nuevo',
      views[0].changeTypeLabel,
      'Etiqueta traducida'
    );
    System.assertEquals(
      'https://example.com/lvl-pul-001.png',
      views[0].imageUrl,
      'Imagen desde DisplayUrl'
    );
  }

  @isTest
  static void nonEntitledProductIsNeverReturned() {
    Map<String, Id> ids = productIdsByCode();
    Id p2 = ids.get('LVL-PUL-002');
    // Existe la novedad de P2, pero el buyer solo está entitled a P1.
    insert item(
      p2,
      p2 + '|NEW|GLOBAL',
      null,
      System.now().addHours(-1),
      System.now().addDays(10),
      'ACTIVE'
    );

    Test.startTest();
    List<LvlupCatalogPulseController.PulseItemView> views = LvlupCatalogPulseController.queryPulse(
      new Set<Id>{ ids.get('LVL-PUL-001') },
      new Set<String>(),
      12
    );
    Test.stopTest();

    System.assertEquals(
      0,
      views.size(),
      'Un producto no entitled nunca se expone'
    );
  }

  @isTest
  static void expiredAndInactiveAreExcluded() {
    Map<String, Id> ids = productIdsByCode();
    Id p1 = ids.get('LVL-PUL-001');
    insert new List<Catalog_Pulse_Item__c>{
      item(
        p1,
        p1 + '|NEW|EXPIRED',
        null,
        System.now().addDays(-20),
        System.now().addDays(-5),
        'ACTIVE'
      ),
      item(
        p1,
        p1 + '|UPDATED|HIDDEN',
        null,
        System.now().addHours(-1),
        System.now().addDays(10),
        'HIDDEN'
      )
    };

    Test.startTest();
    List<LvlupCatalogPulseController.PulseItemView> views = LvlupCatalogPulseController.queryPulse(
      new Set<Id>{ p1 },
      new Set<String>(),
      12
    );
    Test.stopTest();

    System.assertEquals(0, views.size(), 'Ni vencidos ni HIDDEN se devuelven');
  }

  @isTest
  static void segmentFilterKeepsGlobalAndMatching() {
    Map<String, Id> ids = productIdsByCode();
    Id p1 = ids.get('LVL-PUL-001');
    insert new List<Catalog_Pulse_Item__c>{
      item(
        p1,
        p1 + '|NEW|GLOBAL',
        null,
        System.now().addHours(-1),
        System.now().addDays(10),
        'ACTIVE'
      ),
      item(
        p1,
        p1 + '|NEW|GAMING',
        'Gaming Local Buyers',
        System.now().addHours(-1),
        System.now().addDays(10),
        'ACTIVE'
      ),
      item(
        p1,
        p1 + '|NEW|OTHER',
        'Enterprise Buyers',
        System.now().addHours(-1),
        System.now().addDays(10),
        'ACTIVE'
      )
    };

    Test.startTest();
    List<LvlupCatalogPulseController.PulseItemView> views = LvlupCatalogPulseController.queryPulse(
      new Set<Id>{ p1 },
      new Set<String>{ 'Gaming Local Buyers' },
      12
    );
    Test.stopTest();

    System.assertEquals(
      2,
      views.size(),
      'Global + segmento propio; el ajeno se excluye'
    );
  }

  @isTest
  static void adminWithoutBuyerContextReturnsEmpty() {
    Test.startTest();
    List<LvlupCatalogPulseController.PulseItemView> views = LvlupCatalogPulseController.getCatalogPulseForBuyer(
      5
    );
    Test.stopTest();
    System.assertEquals(
      0,
      views.size(),
      'Sin contexto de comprador -> vacío, sin error'
    );
  }

  @isTest
  static void buyerAccountWithoutGroupResolvesNull() {
    Account buyer = new Account(Name = 'Buyer Without Group');
    insert buyer;

    Test.startTest();
    LvlupCatalogPulseController.BuyerContext ctx = LvlupCatalogPulseController.resolveBuyerContext(
      buyer.Id
    );
    Test.stopTest();

    System.assertEquals(
      null,
      ctx,
      'Sin Buyer Group no hay contexto de visibilidad'
    );
  }

  @isTest
  static void resolveBuyerContextResolvesEntitledProductsAndSegment() {
    Id productId = productIdsByCode().get('LVL-PUL-001');

    Account buyer = new Account(Name = 'Entitled Buyer');
    insert buyer;
    // Habilitar la Account como Buyer Account antes de poder añadirla a un grupo (REGLA-002).
    insert new BuyerAccount(
      BuyerId = buyer.Id,
      Name = 'Entitled Buyer',
      IsActive = true
    );

    BuyerGroup buyerGroup = new BuyerGroup(Name = 'Gaming Local Buyers');
    insert buyerGroup;
    insert new BuyerGroupMember(
      BuyerId = buyer.Id,
      BuyerGroupId = buyerGroup.Id
    );

    CommerceEntitlementPolicy policy = new CommerceEntitlementPolicy(
      Name = 'Pulse Test Policy',
      CanViewProduct = true,
      CanViewPrice = true,
      IsActive = true
    );
    insert policy;
    insert new CommerceEntitlementBuyerGroup(
      BuyerGroupId = buyerGroup.Id,
      PolicyId = policy.Id
    );
    insert new CommerceEntitlementProduct(
      ProductId = productId,
      PolicyId = policy.Id
    );

    Test.startTest();
    LvlupCatalogPulseController.BuyerContext ctx = LvlupCatalogPulseController.resolveBuyerContext(
      buyer.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      ctx,
      'Con Buyer Group y entitlement hay contexto'
    );
    System.assert(
      ctx.entitledProductIds.contains(productId),
      'El producto entitled debe resolverse en el contexto'
    );
    System.assert(
      ctx.segmentKeys.contains('Gaming Local Buyers'),
      'El segmento se resuelve como el nombre del Buyer Group'
    );
  }
}
