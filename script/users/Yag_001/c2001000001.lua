Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
    
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    --ATK/DEF gain
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.atktg)
    e2:SetValue(s.atkval)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_FZONE)
    c:RegisterEffect(e2)
    
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    
    --Prevent monster effect activation
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetTargetRange(1,1)
    e4:SetValue(s.aclimit)
    e4:SetCondition(s.actcon)
    c:RegisterEffect(e4)
end

function s.atktg(e,c)
    local isValid = c:IsSetCard(0x77b)
    return isValid
end

function s.atkfilter(c)
    local isValid = c:IsSetCard(0x77b) and c:IsSpellTrap()
    return isValid
end

function s.atkval(e,c)
    if not c then return 0 end
    
    local controller = c:GetControler()
    
    -- Get both banished piles
    local g1 = Duel.GetMatchingGroup(s.atkfilter, controller, LOCATION_REMOVED, 0, nil)
    
    -- Calculate bonus
    local bonus = #g1 * 100
    return bonus
end

function s.actcon(e)
    return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)>=12
end

function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end