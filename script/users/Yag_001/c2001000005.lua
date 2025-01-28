Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon with Field Spell placement (regular effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.regcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--Quick Effect version when Gildentree is on field
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)
	
	--Send both to GY when battling
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.fzfilter(c,tp)
	return c:IsCode(2001000001) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFieldSpell,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsFieldSpell,tp,LOCATION_GRAVE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and s.spcon(e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--Optional Field Spell placement
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.fzfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			if tc then
				local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
				local p=(opt==0) and tp or 1-tp
				local fc=Duel.GetFieldCard(p,LOCATION_FZONE,0)
				if fc then
					Duel.SendtoGrave(fc,REASON_RULE)
					Duel.BreakEffect()
				end
				Duel.MoveToField(tc,tp,p,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	local g=Group.FromCards(e:GetHandler(),bc)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToEffect(e) or not bc or not bc:IsRelateToBattle() then return end
	local g=Group.FromCards(c,bc)
	if Duel.SendtoGrave(g,REASON_EFFECT)==2 
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==2
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end