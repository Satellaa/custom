Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    --First effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Banish to Special Summon Ancestralight
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end
s.listed_series={0x77b,0x78b}

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x78b) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local loc_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ex_loc_count=Duel.GetLocationCountFromEx(tp)
    if chk==0 then return (loc_count>0 or ex_loc_count>0)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local loc_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ex_loc_count=Duel.GetLocationCountFromEx(tp)
    if loc_count<=0 and ex_loc_count<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
        --Return to Extra Deck at end of turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
        end)
        tc:RegisterEffect(e1)
    end
end

function s.filter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(0x77b)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel())
end

function s.spfilter2(c,e,tp,lv)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x78b)
        and c:IsOriginalSetCard(0x78b) and c:GetLevel()<lv
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local loc_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ex_loc_count=Duel.GetLocationCountFromEx(tp)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
    if chk==0 then return (loc_count>0 or ex_loc_count>0)
        and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local loc_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ex_loc_count=Duel.GetLocationCountFromEx(tp)
    if loc_count<=0 and ex_loc_count<=0 then return end
    
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetLevel())
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end