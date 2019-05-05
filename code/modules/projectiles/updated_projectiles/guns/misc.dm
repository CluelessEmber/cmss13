//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. This thing will no doubt pack a punch."
	icon_state = "painless"
	item_state = "painless"
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/gun_minigun.ogg'
	cocked_sound = 'sound/weapons/gun_minigun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	type_of_casings = "cartridge"
	w_class = 5
	force = 20
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_BURST_ON|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/minigun/New(loc, spawn_empty)
	..()
	if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

/obj/item/weapon/gun/minigun/set_gun_config_values()
	fire_delay = config.mlow_fire_delay
	burst_amount = config.max_burst_value
	burst_delay = config.min_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.low_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	burst_scatter_mult = config.lmed_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.med_recoil_value

/obj/item/weapon/gun/minigun/toggle_burst()
	to_chat(usr, "<span class='warning'>This weapon can only fire in bursts!</span>")

//M60
/obj/item/weapon/gun/m60
	name = "\improper M60 General Purpose Machine Gun"
	desc = "The M60. The Pig. The Action Hero's wet dream."
	icon_state = "m60"
	item_state = "m60"
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/gun_m60.ogg'
	cocked_sound = 'sound/weapons/gun_m60_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/m60
	type_of_casings = "cartridge"
	w_class = 4
	force = 20
	flags_gun_features = GUN_BURST_ON|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/m60/New(loc, spawn_empty)
	..()
	attachable_allowed = list(/obj/item/attachable/m60barrel)
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 16)
	if(current_mag && current_mag.current_rounds > 0) load_into_chamber()
	var/obj/item/attachable/m60barrel/Q = new(src)
	Q.Attach(src)
	update_icon()

/obj/item/weapon/gun/m60/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_amount = 5
	burst_delay = config.min_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.min_scatter_value
	burst_scatter_mult = config.low_scatter_value
	scatter_unwielded = config.min_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.min_recoil_value
	empty_sound = 'sound/weapons/gun_empty.ogg'

/obj/item/weapon/gun/m60/toggle_burst()
	to_chat(usr, "<span class='warning'>This weapon can only fire in bursts!</span>")
	
//Spike launcher

/obj/item/weapon/gun/launcher/spike
	name = "spike launcher"
	desc = "A compact Yautja device in the shape of a crescent. It can rapidly fire damaging spikes and automatically recharges."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "spikelauncher"
	muzzle_flash = null // TO DO, add a decent one.
	origin_tech = "combat=7;materials=7"
	unacidable = 1
	fire_sound = 'sound/effects/woodhit.ogg' // TODO: Decent THWOK noise.
	ammo = /datum/ammo/alloy_spike
	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	w_class = 3 //Fits in yautja bags.
	var/spikes = 12
	var/max_spikes = 12
	var/last_regen
	flags_gun_features = GUN_UNUSUAL_DESIGN

/obj/item/weapon/gun/launcher/spike/dropped(mob/living/user)
	add_to_missing_pred_gear(src)
	..()

/obj/item/weapon/gun/launcher/spike/pickup(mob/living/user)
	if(isYautja(user))
		remove_from_missing_pred_gear(src)
	..()

/obj/item/weapon/gun/launcher/spike/Dispose()
	. = ..()
	remove_from_missing_pred_gear(src)
	processing_objects.Remove(src)

/obj/item/weapon/gun/launcher/spike/process()
	if(spikes < max_spikes && world.time > last_regen + 100 && prob(70))
		spikes++
		last_regen = world.time
		update_icon()

/obj/item/weapon/gun/launcher/spike/New()
	..()
	processing_objects.Add(src)
	last_regen = world.time
	update_icon()
	verbs -= /obj/item/weapon/gun/verb/field_strip //We don't want these to show since they're useless.
	verbs -= /obj/item/weapon/gun/verb/toggle_burst
	verbs -= /obj/item/weapon/gun/verb/empty_mag
	verbs -= /obj/item/weapon/gun/verb/use_unique_action

/obj/item/weapon/gun/launcher/spike/set_gun_config_values()
	fire_delay = config.high_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


/obj/item/weapon/gun/launcher/spike/examine(mob/user)
	if(isYautja(user))
		..()
		to_chat(user, "It currently has [spikes] / [max_spikes] spikes.")
	else to_chat(user, "Looks like some kind of...mechanical donut.")

/obj/item/weapon/gun/launcher/spike/update_icon()
	..()
	var/new_icon_state = spikes <=1 ? null : icon_state + "[round(spikes/4, 1)]"
	update_special_overlay(new_icon_state)

/obj/item/weapon/gun/launcher/spike/able_to_fire(mob/user)
	if(!isYautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return

	return ..()

/obj/item/weapon/gun/launcher/spike/load_into_chamber()
	if(spikes > 0)
		in_chamber = create_bullet(ammo)
		spikes--
		return in_chamber

/obj/item/weapon/gun/launcher/spike/reload_into_chamber()
	update_icon()
	return 1

/obj/item/weapon/gun/launcher/spike/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund) spikes++
	return 1





//Syringe Gun

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	matter = list("metal" = 2000)

/obj/item/weapon/gun/syringe/examine(mob/user)
	..()
	if(user != loc) return
	to_chat(user, SPAN_NOTICE(" [syringes.len] / [max_syringes] syringes."))

/obj/item/weapon/gun/syringe/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/reagent_container/syringe))
		var/obj/item/reagent_container/syringe/S = I
		if(S.mode != 2)//SYRINGE_BROKEN in syringes.dm
			if(syringes.len < max_syringes)
				user.drop_inv_item_to_loc(I, src)
				syringes += I
				update_icon()
				to_chat(user, SPAN_NOTICE(" You put the syringe in [src]."))
				to_chat(user, SPAN_NOTICE(" [syringes.len] / [max_syringes] syringes."))
			else
				to_chat(usr, "<span class='danger'>[src] cannot hold more syringes.</span>")
		else
			to_chat(usr, "<span class='danger'>This syringe is broken!</span>")


/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/syringe/update_icon()
	..()
	if(syringes.len)
		icon_state = base_gun_icon
	else
		icon_state = base_gun_icon + "_e"


/obj/item/weapon/gun/syringe/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(syringes.len)
		spawn(0) fire_syringe(target,user)
	else
		to_chat(usr, "<span class='danger'>[src] is empty.</span>")

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/reagent_container/syringe/S = syringes[1]
		if((!S) || (!S.reagents))	//ho boy! wot runtimes!
			return
		S.reagents.trans_to(D, S.reagents.total_volume)
		syringes -= S
		update_icon()
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("[user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R]) (<A HREF='?_src_=admin_holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
						msg_admin_attack("UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R]) (<A HREF='?_src_=admin_holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					M.visible_message("<span class='danger'>[M] is hit by the syringe!</span>")

					if(M.can_inject())
						if(D.reagents)
							D.reagents.trans_to(M, 15)
					else
						M.visible_message("<span class='danger'>The syringe bounces off [M]!</span>")

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D) spawn(10) qdel(D)

		return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		create_reagents(15)
		..()

