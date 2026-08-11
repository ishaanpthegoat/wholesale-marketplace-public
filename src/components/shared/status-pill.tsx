import { Badge, type BadgeProps } from "@/components/ui/badge";

export type OfferStatus = "pending" | "accepted" | "declined" | "auto_declined" | "expired";
export type OrderStatus =
  | "awaiting_payment"
  | "paid"
  | "awaiting_shipment"
  | "in_transit"
  | "delivered"
  | "complete"
  | "disputed"
  | "cancelled";

/**
 * Labels and treatments are fixed by docs/COPY.md § "Offer statuses".
 *
 * Two things here are load-bearing:
 *  - `auto_declined` reads "Not selected", never "Declined". The buyer did
 *    nothing wrong; somebody else simply bid more.
 *  - `declined` is neutral, not red. docs/BRAND.md §11(i).
 */
const OFFER: Record<OfferStatus, { label: string; variant: BadgeProps["variant"] }> = {
  pending: { label: "Pending", variant: "pending" },
  accepted: { label: "Accepted", variant: "accepted" },
  declined: { label: "Declined", variant: "declined" },
  auto_declined: { label: "Not selected", variant: "notSelected" },
  expired: { label: "Expired", variant: "expired" },
};

const ORDER: Record<OrderStatus, { label: string; variant: BadgeProps["variant"] }> = {
  awaiting_payment: { label: "Awaiting payment", variant: "warning" },
  paid: { label: "Paid", variant: "accepted" },
  awaiting_shipment: { label: "Awaiting shipment", variant: "pending" },
  in_transit: { label: "In transit", variant: "pending" },
  delivered: { label: "Delivered", variant: "accepted" },
  complete: { label: "Complete", variant: "accepted" },
  disputed: { label: "Disputed", variant: "danger" },
  cancelled: { label: "Cancelled", variant: "expired" },
};

export function OfferStatusPill({ status, ...props }: { status: OfferStatus } & BadgeProps) {
  const { label, variant } = OFFER[status];
  return (
    <Badge variant={variant} dot {...props}>
      {label}
    </Badge>
  );
}

export function OrderStatusPill({ status, ...props }: { status: OrderStatus } & BadgeProps) {
  const { label, variant } = ORDER[status];
  return (
    <Badge variant={variant} dot {...props}>
      {label}
    </Badge>
  );
}
