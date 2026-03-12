// ==============================================
// Generated from SysML v2 model — DO NOT EDIT
// Source: model/domain/coffeeshop.sysml
// Generator: gen_typescript_types.py
// Hand-fixed: enum doc block parsing, externalRefs
// ==============================================

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

export enum OrderStatus {
  placed = "placed",
  inPreparation = "inPreparation",
  ready = "ready",
  collected = "collected",
  cancelled = "cancelled",
}

export interface ExternalReference {
  referenceType: string;
  referenceId: string;
  referenceSource: string;
  referenceNotes: string;
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

export interface CatalogueEntry {
  pricePence: number;
  priceDisplay: string;
  availability: AvailabilityStatus;
  provisionType: ProvisionType;
  effectiveDate: string;
  statusNotes: string;
  item: MenuItem;
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

export interface OrderLine {
  quantity: number;
  item: MenuItem;
}

export interface Order {
  orderNumber: number;
  status: OrderStatus;
  totalPrice: number;
  customer: Customer;
  lines: OrderLine[];
}
