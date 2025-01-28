--Ancestralight Dragon
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Fusion
	c:EnableReviveLimit()
	
	--Set from banished and destroy on Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	
	--Banish from GY to add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x77b}

function s.setfilter(c)
	return c:IsSetCard(0x77b) and c:IsSpellTrap() and c:IsFaceup() and c:IsSSetable()
 end
 
 function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if ft<0 then return false end
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_REMOVED,0,nil)
		return #g>0 and (ft>0 or g:IsExists(Card.IsType,1,nil,TYPE_FIELD))
	end
 end
 
 function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<0 then return end
	
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(99,ft),aux.dncheck,1,tp,HINTMSG_SET)
	
	if #sg>0 and Duel.SSet(tp,sg)>0 then
		local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)
		local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if ct>0 and #dg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg2=dg:Select(tp,ct,ct,nil)
			Duel.Destroy(sg2,REASON_EFFECT)
		end
	end
 end

function s.thfilter(c)
	return c:IsSetCard(0x77b) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end