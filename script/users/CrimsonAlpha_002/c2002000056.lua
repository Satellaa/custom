 --Wynn, Charmer of Gusto
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetCountLimit(1,{id,0})
		-- e1:SetCondition(s.cond)
		e1:SetTarget(s.target)
		e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={27980138}
s.listed_series={SET_GUSTO}
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.filter(c,e,tp)
	return (c:IsCode(27980138) or c:IsSetCard(SET_GUSTO)) 
		and c:IsSpellTrap()
		and (c:IsSSetable() and c:IsAbleToHand())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		Card.IsSSetable,
		function(c)
			Duel.SSet(tp,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			if tc:IsType(TYPE_QUICKPLAY) then
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			elseif  tc:IsType(TYPE_TRAP) then
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			end
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end,
		aux.Stringid(id,1)
	)
end