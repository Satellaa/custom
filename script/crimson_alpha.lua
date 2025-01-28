-- initialize script extensions
Duel.LoadScript ("constant_ext.lua")
Duel.LoadScript ("utility_ext.lua")
Duel.LoadScript ("cards_specific_functions_ext.lua")
Duel.LoadScript ("proc_fusion_spell_ext.lua")
Duel.LoadScript ("proc_ritual_ext.lua")
Duel.LoadScript ("proc_synchro_ext.lua")
Duel.LoadScript ("proc_pendulum_ext.lua")
Duel.LoadScript ("proc_link_ext.lua")
Duel.LoadScript ("custom_set_codes.lua")

-- update globals
regeff_list[REGISTER_FLAG_DETACH_XMAT]=511002571
regeff_list[REGISTER_FLAG_CARDIAN]=511001692
regeff_list[REGISTER_FLAG_THUNDRA]=12081875
regeff_list[REGISTER_FLAG_ALLURE_LVUP]=511310036
regeff_list[REGISTER_FLAG_TELLAR]=58858807
regeff_list[REGISTER_FLAG_DRAGON_RULER]=101208047

regeff_list[CUSTOM_REGISTER_FLIP]=TYPE_FLIP
regeff_list[CUSTOM_REGISTER_LIMIT]=EFFECT_UNIQUE_CHECK
regeff_list[CUSTOM_REGISTER_ZEFRA]=2002000083


