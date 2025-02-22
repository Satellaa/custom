--リチュアの写魂鏡
--Gishki Photomirror
--Modified for CrimsonAlpha
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,0x3a)
end
s.listed_series={0x3a}
function s.filter(c,e,tp,lp)
	if not c:IsRitualMonster() or not c:IsSetCard(0x3a) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then
		return false
	end
	return lp>c:GetLevel()*500
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(tp)
	local c=e:GetHandler()
	--- Custom ---
	local location=LOCATION_HAND
	local extra_loc=Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
	local ec=Duel.IsExistingMatchingCard(s.filter,tp,location,0,1,nil,e,tp,lp)
	local ec_extra
	--------------
	if chk==0 then
		--- Custom ---
		if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
			ec_extra=Duel.IsExistingMatchingCard(s.filter,tp,extra_loc,0,1,nil,e,tp,lp)
			if ec_extra and ec then
				location=location+extra_loc
			elseif ec_extra and not ec then
				location=extra_loc
			end
		else 
			location=location
		end
		--------------
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,location,0,1,nil,e,tp,lp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lp=Duel.GetLP(tp)
	--- Custom ---
	local location=LOCATION_HAND
	local extra_loc=Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
	local ec=Duel.IsExistingMatchingCard(s.filter,tp,location,0,1,nil,e,tp,lp)
	local ec_extra
	if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
		ec_extra=Duel.IsExistingMatchingCard(s.filter,tp,extra_loc,0,1,nil,e,tp,lp)
		if ec_extra and ec then
			if Duel.SelectYesNo(tp,aux.Stringid(CUSTOM_RITUAL_LOCATION,1)) then
				Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,extra_loc)
				location = extra_loc
			end
		elseif ec_extra and not ec then
			Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,extra_loc)
			location = extra_loc
		end
	end
	--------------
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,location,0,1,1,nil,e,tp,lp)
	local tc=tg:GetFirst()
	if tc then
		mustpay=true
		Duel.PayLPCost(tp,tc:GetLevel()*500)
		mustpay=false
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
