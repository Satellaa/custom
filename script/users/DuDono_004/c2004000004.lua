-- Nemleria Dream Creator - Pyjama
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
  -- handtrap
  local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0, TIMING_END_PHASE)
	e1:SetCountLimit(1, {id, 0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
  -- protecc
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_CHAINING)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCost(s.prcost)
  e2:SetTarget(s.prtg)
  e2:SetOperation(s.prop)
  c:RegisterEffect(e2)
end
s.listed_names = {CARD_DREAMING_NEMLERIA}
s.listed_series = {SET_NEMLERIA}

function s.handfilter(c)
  return c:IsAbleToHand() and not c:IsAbleToExtra()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) and
			Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1, nil, CARD_DREAMING_NEMLERIA)
	end
	local eepy = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, CARD_DREAMING_NEMLERIA)
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, e:GetHandler())
	Duel.SendtoExtraP(eepy, nil, REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if
		c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 and
			Duel.IsExistingMatchingCard(s.handfilter, tp, 0, LOCATION_ONFIELD, 1, nil) and
			Duel.SelectYesNo(tp, aux.Stringid(id, 0))
	 then
		Duel.BreakEffect()
		local boom = Duel.SelectMatchingCard(tp, s.handfilter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
		if Duel.SendtoHand(boom, nil, REASON_EFFECT) > 0 then
			Duel.Draw(1 - tp, 1, REASON_EFFECT)
		end
	end
end

function s.prfilter(c)
  return c:IsSetCard(SET_NEMLERIA)
end
function s.prfilter2(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.prcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.prtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DREAMING_NEMLERIA),tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingTarget(s.prfilter,tp,LOCATION_ONFIELD,0,1,nil)
  end
  Duel.SelectTarget(tp,s.prfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c = e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3100)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
	tc:RegisterEffect(e1)
end