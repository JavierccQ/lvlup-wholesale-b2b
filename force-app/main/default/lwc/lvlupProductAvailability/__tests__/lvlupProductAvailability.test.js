import { createElement } from "lwc";
import LvlupProductAvailability from "c/lvlupProductAvailability";
import getProductPurchaseInfo from "@salesforce/apex/LvlupQuickBuyController.getProductPurchaseInfo";

// Mock del wire adapter de Apex: nos deja emitir datos/errores de forma controlada.
jest.mock(
  "@salesforce/apex/LvlupQuickBuyController.getProductPurchaseInfo",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);

const MOCK_INFO = {
  productId: "01t000000000001AAA",
  name: "LvlUp Gaming Laptop 15",
  sku: "LVL-LAP-001",
  imageUrl: null,
  unitPrice: 1349,
  stock: 120,
  minQuantity: 5,
  increment: 5,
  maxQuantity: 100
};

function createComponent(recordId = "01t000000000001AAA") {
  const element = createElement("c-lvlup-product-availability", {
    is: LvlupProductAvailability
  });
  element.recordId = recordId;
  document.body.appendChild(element);
  return element;
}

function flushPromises() {
  return Promise.resolve();
}

describe("c-lvlup-product-availability", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("pide los datos al Apex con el recordId de la página", async () => {
    createComponent("01t000000000123AAA");
    await flushPromises();

    expect(getProductPurchaseInfo.getLastConfig()).toEqual({
      productId: "01t000000000123AAA"
    });
  });

  it("renderiza el panel de stock con stock y case pack cuando hay datos", async () => {
    const element = createComponent();
    getProductPurchaseInfo.emit(MOCK_INFO);
    await flushPromises();

    const panel = element.shadowRoot.querySelector(
      "c-lvlup-stock-availability-panel"
    );
    expect(panel).not.toBeNull();
    expect(panel.stock).toBe(120);
    expect(panel.casePack).toBe(5);
  });

  it("no renderiza nada cuando el wire falla", async () => {
    // Silenciamos el console.error diagnóstico para no ensuciar la salida del test.
    const consoleError = jest
      .spyOn(console, "error")
      .mockImplementation(() => {});

    const element = createComponent();
    getProductPurchaseInfo.error();
    await flushPromises();

    expect(
      element.shadowRoot.querySelector("c-lvlup-stock-availability-panel")
    ).toBeNull();
    expect(consoleError).toHaveBeenCalled();

    consoleError.mockRestore();
  });

  it("no renderiza nada mientras no llegan datos", async () => {
    const element = createComponent();
    await flushPromises();

    expect(
      element.shadowRoot.querySelector("c-lvlup-stock-availability-panel")
    ).toBeNull();
  });
});
