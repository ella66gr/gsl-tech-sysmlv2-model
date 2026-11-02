// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop); model/business-metamodel-general.sysml
// Generator: generation/ts_types.py
// ============================================================

export enum DrinkSize {
  small = "small",
  medium = "medium",
  large = "large",
}

export enum MilkOption {
  whole = "whole",
  semi = "semi",
  oat = "oat",
  soy = "soy",
  almond = "almond",
  none = "none",
}

export enum ItemCategory {
  hotDrink = "hotDrink",
  coldDrink = "coldDrink",
  food = "food",
}

export enum AvailabilityStatus {
  active = "active",
  discontinued = "discontinued",
  seasonal = "seasonal",
  temporarilyUnavailable = "temporarilyUnavailable",
}

export enum ProvisionType {
  prepared = "prepared",
  boughtIn = "boughtIn",
  hybrid = "hybrid",
}

export enum StockStatus {
  inStock = "inStock",
  low = "low",
  outOfStock = "outOfStock",
  onOrder = "onOrder",
}

export enum StaffRole {
  barista = "barista",
  manager = "manager",
  kitchenStaff = "kitchenStaff",
}

// Status axes: each axis's value type, and each type's axis tuple

/** OrderLine preparation: values in declared order; default queued. */
export const orderLinePreparationValues = ["queued", "inPreparation", "ready", "collected", "cancelled"] as const;
export type OrderLinePreparationValue = (typeof orderLinePreparationValues)[number];

/** The axis tuple of OrderLine. */
export interface OrderLineAxisTuple {
  preparation: OrderLinePreparationValue;
}

/** Order lifecycle: values in declared order; default placed. */
export const orderLifecycleValues = ["placed", "inPreparation", "ready", "collected", "cancelled"] as const;
export type OrderLifecycleValue = (typeof orderLifecycleValues)[number];

/** Order payment: values in declared order; default unpaid. */
export const orderPaymentValues = ["unpaid", "paid"] as const;
export type OrderPaymentValue = (typeof orderPaymentValues)[number];

/** The axis tuple of Order. */
export interface OrderAxisTuple {
  lifecycle: OrderLifecycleValue;
  payment: OrderPaymentValue;
}

export interface MenuItem {
  name: string;
  category: ItemCategory;
  isVegan: boolean;
  description: string;
  externalRefs: ExternalReference[];
}

export interface Drink extends MenuItem {
  size: DrinkSize;
  milkChoice: MilkOption;
  isCaffeinated: boolean;
}

export interface FoodItem extends MenuItem {
  isGlutenFree: boolean;
  servedWarm: boolean;
}

export interface CatalogueEntry extends ServiceConceptCatalogueEntry {
  pricePence: number;
  priceDisplay: string;
  availability: AvailabilityStatus;
  provisionKind: ProvisionType;
  menuItem: MenuItem;
}

export interface InventoryRecord {
  quantityOnHand: number;
  stockStatus: StockStatus;
  lowStockThreshold: number;
  lastRestocked: string;
  quantityNotes: string;
  catalogueEntry: CatalogueEntry;
}

export interface Person {
  firstName: string;
  lastName: string;
}

export interface Customer extends Person {
  loyaltyPoints: number;
  isMember: boolean;
}

export interface StaffMember extends Person {
  role: StaffRole;
  hoursPerWeek: number;
}

export interface OrderLine extends CanonicalRuntimeType {
  quantity: number;
  beneficiaryLabel?: string;
  beneficiaryContactRef?: string;
  menuItem: MenuItem;
  order: Order;
  /** The status axis tuple: one value per declared axis. */
  axes: OrderLineAxisTuple;
}

export interface Order extends CanonicalRuntimeType {
  orderNumber: number;
  totalPrice: number;
  orderingParty: ServiceParticipant;
  serviceSubject: ServiceSubject;
  lines: OrderLine[];
  /** The status axis tuple: one value per declared axis. */
  axes: OrderAxisTuple;
}

// Platform defs used by this package (from the platform model)

/** BusinessMetamodelGeneral::CanonicalRuntime::CanonicalRuntimeType */
export interface CanonicalRuntimeType {
}

/** BusinessMetamodelGeneral::ServiceConcept::CatalogueEntry */
export interface ServiceConceptCatalogueEntry {
  entryName: string;
  itemReference: string;
  pricingDescription: string;
  availabilityStatus: string;
  provisionType: string;
  effectiveDate: string;
  statusNotes: string;
}

/** BusinessMetamodelGeneral::ServiceConcept::ExternalReference */
export interface ExternalReference {
  referenceType: string;
  referenceId: string;
  referenceSource: string;
  referenceNotes: string;
}

/** BusinessMetamodelGeneral::ServiceConcept::ServiceParticipant */
export interface ServiceParticipant {
  participantName: string;
  participantRole: string;
  entityDescription: string;
  relationshipToEngagement: string;
  statusNotes: string;
}

/** BusinessMetamodelGeneral::ServiceConcept::ServiceSubject */
export interface ServiceSubject {
  subjectName: string;
  entityDescription: string;
  independentNeeds: string;
  conditionNotes: string;
  statusNotes: string;
}
