--Proto Aquamirror
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.spfilter(c,e,tp)
	return c:IsRitualMonster() 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.filter(c,e,tp)
	return c:IsControler(1-tp) 
		and c:IsCanBeRitualMaterial(sc) 
		and not c:IsImmuneToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local location=LOCATION_HAND+LOCATION_GRAVE
	local extra_loc=Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
	local ec=Duel.IsExistingMatchingCard(s.spfilter,tp,location,0,1,nil,e,tp)
	local ec_extra
	if chkc then return s.filter(chkc,e,tp) and eg:IsContains(chkc) end
	if chk==0 and eg and eg:IsExists(s.filter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0   then
		if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
			ec_extra=Duel.IsExistingMatchingCard(s.spfilter,tp,extra_loc,0,1,nil,e,tp)
			if ec_extra and ec then
				return ec
					or ec_extra
			elseif ec_extra and not ec then
				return ec_extra
			end
		else 
			return ec
		end
	end
	-- Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,location)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local location=LOCATION_HAND+LOCATION_GRAVE
	local extra_loc=Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
	local ec=Duel.IsExistingMatchingCard(s.spfilter,tp,location,0,1,nil,e,tp)
	local ec_extra
	if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
		ec_extra=Duel.IsExistingMatchingCard(s.spfilter,tp,extra_loc,0,1,nil,e,tp)
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
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,location,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	if #tg==0 then return end
	sc:SetMaterial(tg)
	Duel.ReleaseRitualMaterial(tg)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)==0 then return end
	sc:CompleteProcedure()
end