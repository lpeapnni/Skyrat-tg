/obj/item/reagent_brick/hash
	name = "hash brick"
	desc = "A brick of hash. Good for transport!"
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	icon_state = "hashbrick"
	packed_item = /obj/item/bongable/hash
	packed_amount = 4
	brick_reagent = /datum/reagent/drug/thc/processed
	reagent_amount = 80

/datum/crafting_recipe/hash_brick
	result = /obj/item/reagent_brick/hash
	reqs = list(/obj/item/bongable/hash = 4)
	parts = list(/obj/item/bongable/hash = 4)
	time = 20
	category = CAT_CHEMISTRY //i might just make a crafting category for drugs at some point
