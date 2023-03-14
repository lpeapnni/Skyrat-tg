// speed modifier
/datum/movespeed_modifier/reagent/bluesky
	multiplicative_slowdown = -0.4

// the recipe

// this is a little easier and less dangerous than regular meth synthesis, but more affected by impurity
// no weird shit with purity affecting rate of heating up, and if you do blow it up the results are much less catastrophic
/datum/chemical_reaction/bluesky
	results = list(/datum/reagent/drug/bluesky = 4)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/ammonia = 1, /datum/reagent/hydrogen = 1)
	required_temp = 374
	overheat_temp = 400 // more forgiving heat range
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 1.4
	thermic_constant = 3 // you can only successfully pull off 15u without buffers or cooling
	H_ion_release = -0.025
	rate_up_lim = 12.5
	purity_min = 0.5 //100u will natrually just dip under this w/ no buffer
	reaction_flags = REACTION_HEAT_ARBITARY
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_DRUG | REACTION_TAG_DANGEROUS

// nice going dumbass
/datum/chemical_reaction/bluesky/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	explode_deafen(holder, equilibrium)
	clear_reagents(holder)

/datum/chemical_reaction/bluesky/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	explode_deafen(holder, equilibrium)
	clear_reagents(holder)

// the chemical

/datum/reagent/drug/bluesky
	name = "Blue Sky"
	description = "A variant of methamphetamine synthsized via reductive amination. Easier to produce, but more prone to quality issues."
	reagent_state = LIQUID
	color = "#78C8FA" //best case scenario is the "default", gets muddled depending on purity
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 12) //4.8 per 2 seconds

/datum/reagent/drug/bluesky/on_new(data)
	. = ..()
	var/effective_impurity = min(1, (1 - creation_purity)/0.5)
	color = BlendRGB(initial(color), "#FAFAFA", effective_impurity)

/datum/reagent/drug/bluesky/on_merge(data, amount)
	. = ..()
	var/effective_impurity = min(1, (1 - creation_purity)/0.5)
	color = BlendRGB(initial(color), "#FAFAFA", effective_impurity)

/datum/reagent/drug/bluesky/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/bluesky/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	..()

/datum/reagent/drug/bluesky/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice("[high_message]"))
	var/strength_multiplier = creation_purity**3
	affected_mob.add_mood_event("tweaking", /datum/mood_event/stimulant_medium, name)
	affected_mob.AdjustStun(-35 * strength_multiplier * REM * delta_time)
	affected_mob.AdjustKnockdown(-35 * strength_multiplier * REM * delta_time)
	affected_mob.AdjustUnconscious(-35 * strength_multiplier * REM * delta_time)
	affected_mob.AdjustParalyzed(-35 * strength_multiplier * REM * delta_time)
	affected_mob.AdjustImmobilized(-35 * strength_multiplier * REM * delta_time)
	affected_mob.adjustStaminaLoss(-2 * strength_multiplier * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.set_jitter_if_lower(4 SECONDS * REM * delta_time)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(2, 5) * REM * delta_time, required_organtype = affected_organtype) // more brain damage than usual
	if(DT_PROB(2.5, delta_time))
		affected_mob.emote(pick("twitch", "shiver"))
	..()
	. = TRUE

/datum/reagent/drug/bluesky/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && !ismovable(affected_mob.loc))
		for(var/i in 1 to round(4 * REM * delta_time, 1))
			step(affected_mob, pick(GLOB.cardinals))
	if(DT_PROB(10, delta_time))
		affected_mob.emote("laugh")
	if(DT_PROB(18, delta_time))
		affected_mob.visible_message(span_danger("[affected_mob]'s hands flip out and flail everywhere!"))
		affected_mob.drop_all_held_items()
	..()
	affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5, 10) / 10) * REM * delta_time, required_organtype = affected_organtype)
	. = TRUE
