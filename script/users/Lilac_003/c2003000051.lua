-- Scorching Managram
-- Scripted by Lilac
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcEqual(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
end