class_name RealmCommerce
extends RefCounted

# Platform adapters live outside the simulation. Never grant inventory from UI callbacks.
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/commerce.json"))
var billing_provider: Object
var ads_provider: Object

func purchase(product_id: String) -> Dictionary:
	if not config.billing.enabled: return {"ok":false,"code":"not_configured"}
	if not config.billing.products.has(product_id): return {"ok":false,"code":"unknown_product"}
	if not is_instance_valid(billing_provider) or not billing_provider.has_method("purchase"):
		return {"ok":false,"code":"provider_unavailable"}
	return await billing_provider.purchase(product_id)

func restore_purchases() -> Dictionary:
	if not config.billing.enabled or not is_instance_valid(billing_provider) or not billing_provider.has_method("restore_purchases"):
		return {"ok":false,"code":"not_configured"}
	return await billing_provider.restore_purchases()

func request_rewarded(placement: String) -> Dictionary:
	if not config.ads.enabled: return {"ok":false,"code":"not_configured"}
	if placement not in config.ads.rewarded_placements: return {"ok":false,"code":"unknown_placement"}
	if not is_instance_valid(ads_provider) or not ads_provider.has_method("show_rewarded"):
		return {"ok":false,"code":"provider_unavailable"}
	return await ads_provider.show_rewarded(placement)
