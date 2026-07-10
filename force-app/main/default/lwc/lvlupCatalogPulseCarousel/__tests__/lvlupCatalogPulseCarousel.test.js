import { createElement } from "lwc";
import LvlupCatalogPulseCarousel from "c/lvlupCatalogPulseCarousel";
import getCatalogPulseForBuyer from "@salesforce/apex/LvlupCatalogPulseController.getCatalogPulseForBuyer";

// Mock del wire adapter de Apex: nos deja emitir datos/errores de forma controlada.
jest.mock(
  "@salesforce/apex/LvlupCatalogPulseController.getCatalogPulseForBuyer",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return { default: createApexTestWireAdapter(jest.fn()) };
  },
  { virtual: true }
);

const MOCK_ITEMS = [
  {
    id: "a01000000000001AAA",
    productId: "01t000000000001AAA",
    productName: "Consola LvlUp X",
    sku: "LVL-CON-001",
    imageUrl: "https://example.com/lvl-con-001.png",
    changeType: "NEW",
    changeTypeLabel: "Nuevo",
    title: "Nuevo producto disponible",
    message: "Se ha añadido Consola LvlUp X a tu catálogo.",
    priority: "HIGH"
  }
];

function createComponent() {
  const element = createElement("c-lvlup-catalog-pulse-carousel", {
    is: LvlupCatalogPulseCarousel
  });
  document.body.appendChild(element);
  return element;
}

function flushPromises() {
  return Promise.resolve();
}

describe("c-lvlup-catalog-pulse-carousel", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("renderiza una tarjeta por novedad cuando hay datos", async () => {
    const element = createComponent();
    getCatalogPulseForBuyer.emit(MOCK_ITEMS);
    await flushPromises();

    const cards = element.shadowRoot.querySelectorAll(".pulse-card");
    expect(cards.length).toBe(1);

    const badge = element.shadowRoot.querySelector(".pulse-badge_new");
    expect(badge.textContent).toBe("Nuevo");
  });

  it("muestra el estado vacío cuando no hay novedades", async () => {
    const element = createComponent();
    getCatalogPulseForBuyer.emit([]);
    await flushPromises();

    expect(element.shadowRoot.querySelector(".pulse-empty")).not.toBeNull();
    expect(element.shadowRoot.querySelector(".pulse-track")).toBeNull();
  });

  it("muestra el estado de error cuando el wire falla", async () => {
    const element = createComponent();
    getCatalogPulseForBuyer.error();
    await flushPromises();

    expect(element.shadowRoot.querySelector(".pulse-error")).not.toBeNull();
  });

  it("respeta hideWhenEmpty y no pinta el estado vacío", async () => {
    const element = createComponent();
    element.hideWhenEmpty = true;
    getCatalogPulseForBuyer.emit([]);
    await flushPromises();

    expect(element.shadowRoot.querySelector(".pulse-empty")).toBeNull();
  });
});
