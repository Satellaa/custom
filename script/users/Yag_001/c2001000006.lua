Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x77b),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	
	--Place Pendulums in Scales on Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	
	--Move monster to Pendulum Zone and draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
end
s.listed_series={0x77b}

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.penfilter(c)
	return c:IsSetCard(0x77b) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_EXTRA,0,2,nil) end
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then 
        return 
    end
    local g=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_EXTRA,0,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sg=g:Select(tp,2,2,nil)
    if #sg~=2 then return end
    local tc1,tc2=sg:GetFirst(),sg:GetNext()
    if Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) then
        Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        Duel.MoveToField(tc2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    elseif Duel.CheckLocation(tp,LOCATION_PZONE,0) then
        Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

function s.pzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.pzfilter(chkc) end
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingTarget(s.pzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	if not Duel.IsExistingTarget(s.pzfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.pzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end