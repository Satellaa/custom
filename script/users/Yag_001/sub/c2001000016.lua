Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    
    --Cannot be destroyed by battle
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    --Gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    
    --Protection from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.protg)
    e3:SetOperation(s.proop)
    c:RegisterEffect(e3)
end
s.listed_series={0x77b}
s.listed_names={2001000013} --Hallowfall Magic - Wyrmgate

function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x77b) and c:IsAbleToHand()
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
    if #g>0 then
        local tc=g:GetFirst()
        local atk=tc:GetAttack()
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end

function s.protg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsSetCard(0x77b) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,0x77b),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,0x77b),tp,LOCATION_MZONE,0,1,1,nil)
end

function s.proop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        --Cannot be destroyed by battle or card effects
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(3008)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end