--Hallowfall Enchanted Cavalry
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself and Set banished S/T
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.regcon)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

	--Quick Effect version when Gildentree is on field
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)
	
	--Destroy on S/T banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={0x77b}

--Special Summon functions
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2001000001),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x77b) and c:IsSpellTrap() and c:IsSSetable()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then 
        if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
        
        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil)
        return #g>0 and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or g:IsExists(Card.IsType,1,nil,TYPE_FIELD))
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
        and tc:IsRelateToEffect(e) then
        Duel.SSet(tp,tc)
    end
end

function s.cfilter(c,tp)
	return c:IsSetCard(0x77b) and c:IsSpellTrap() and c:IsPreviousControler(tp)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end