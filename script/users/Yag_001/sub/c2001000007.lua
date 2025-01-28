--Hallowfall Angel
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

    --Pendulum Effect: Special Summon and negate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
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

function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x77b) and c:IsType(TYPE_SYNCHRO)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)>0 then
        --Select and negate a face-up card
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            local tc=g:GetFirst()
            Duel.HintSelection(g)
            --Negate its effects
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end

function s.gyfilter(c,e,tp)
    return c:IsSetCard(0x77b) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
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
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end