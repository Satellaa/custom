--Hallowfall Enchanted Templar
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself by sending S/T to GY (regular effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.regcon) --Added condition
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--Quick Effect version when Gildentree is on field
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)
	
	--Level increase for banished S/T
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.lvval)
	c:RegisterEffect(e3)
end
s.listed_series={0x77b}

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.cfilter(c)
	return c:IsSetCard(0x77b) and c:IsSpellTrap() and c:IsAbleToGrave()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.lvfilter(c)
	return c:IsSetCard(0x77b) and c:IsSpellTrap() and c:IsFaceup()
end

function s.lvval(e,c)
	return Duel.GetMatchingGroupCount(s.lvfilter,c:GetControler(),LOCATION_REMOVED,0,nil)
end