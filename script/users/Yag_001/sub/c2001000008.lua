--Hallowfall Guardian
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	--Must be Special Summoned from Pendulum Zone
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

	--Pendulum Effect: Special Summon and banish battling monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--Special Summon from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
s.listed_series={0x77b}

--Special Summon limit
function s.splimit(e,se,sp,st)
    return se:GetHandler()==e:GetHandler() and se:GetOwner()==e:GetOwner()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then 
        return false 
    end
    if d:IsControler(tp) then a,d=d,a end
    e:SetLabelObject(d)
    local result = a:IsSetCard(0x77b) and a:IsType(TYPE_SYNCHRO)
    return result
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    local canSummon = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
    if chk==0 then return canSummon
        and tc and tc:IsAbleToRemove() end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if c:IsRelateToEffect(e) then
        local success = Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)
        if success>0 and tc and tc:IsRelateToBattle() then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end
end

function s.gyfilter(c,e,tp)
	return c:IsSetCard(0x77b) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end