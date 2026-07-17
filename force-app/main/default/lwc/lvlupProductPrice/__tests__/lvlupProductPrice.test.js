import { createElement } from "lwc";
import LvlupProductPrice from "c/lvlupProductPrice";
import getProductPrice from "@salesforce/apex/LvlupProductPriceController.getProductPrice";

// Mock del wire adapter de Apex: nos deja emitir datos/errores de forma controlada.
jest.mock(
  "@salesforce/apex/LvlupProductPriceController.getProductPrice",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);

const MOCK_PRICE = {
  unitPrice: 1349,
  listPrice: 1499,
  currencyIsoCode: "USD"
};

function createComponent(productId = "01t000000000001AAA") {
  const element = createElement("c-lvlup-product-price", {
    is: LvlupProductPrice
  });
  element.productId = productId;
  document.body.appendChild(element);
  return element;
}

function flushPromises() {
  return Promise.resolve();
}

describe("c-lvlup-product-price", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("pide el precio al Apex con el productId del item", async () => {
    createComponent("01t000000000123AAA");
    await flushPromises();

    expect(getProductPrice.getLastConfig()).toEqual({
      productId: "01t000000000123AAA"
    });
  });

  it("renderiza precio negociado y tachado formateados", async () => {
    const element = createComponent();
    getProductPrice.emit(MOCK_PRICE);
    await flushPromises();

    const unit = element.shadowRoot.querySelector(".unit-price");
    const list = element.shadowRoot.querySelector(".list-price");
    expect(unit.textContent).toBe("$1,349.00");
    expect(list.textContent).toBe("$1,499.00");
  });

  it("oculta el tachado cuando no hay listPrice", async () => {
    const element = createComponent();
    getProductPrice.emit({
      unitPrice: 899,
      listPrice: null,
      currencyIsoCode: "USD"
    });
    await flushPromises();

    expect(element.shadowRoot.querySelector(".unit-price").textContent).toBe(
      "$899.00"
    );
    expect(element.shadowRoot.querySelector(".list-price")).toBeNull();
  });

  it("no renderiza nada sin precio negociado (p. ej. usuario interno)", async () => {
    const element = createComponent();
    getProductPrice.emit({
      unitPrice: null,
      listPrice: null,
      currencyIsoCode: "USD"
    });
    await flushPromises();

    expect(element.shadowRoot.querySelector(".price")).toBeNull();
  });

  it("no renderiza nada cuando el wire falla", async () => {
    const consoleError = jest
      .spyOn(console, "error")
      .mockImplementation(() => {});

    const element = createComponent();
    getProductPrice.error();
    await flushPromises();

    expect(element.shadowRoot.querySelector(".price")).toBeNull();
    expect(consoleError).toHaveBeenCalled();

    consoleError.mockRestore();
  });
});
