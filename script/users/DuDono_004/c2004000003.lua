-- Nemleria Dream Creator - Veilleuse
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
	-- handtrap
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0, TIMING_END_PHASE)
	e1:SetCountLimit(1, {id, 0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- search spell
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, {id, 1})
	e2:SetCost(s.searchcost)
	e2:SetTarget(s.searchtg)
	e2:SetOperation(s.searchop)
	c:RegisterEffect(e2)
	-- return sleepy girl
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, {id, 2})
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
end
s.listed_names = {CARD_DREAMING_NEMLERIA}
s.listed_series = {SET_NEMLERIA}

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
			Duel.IsExistingMatchingCard(c.IsDestructable, tp, 0, LOCATION_ONFIELD, 1, nil) and
			Duel.SelectYesNo(tp, aux.Stringid(id, 0))
	 then
		Duel.BreakEffect()
		local boom = Duel.SelectMatchingCard(tp, c.IsDestructable, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
		if Duel.Destroy(boom, REASON_EFFECT) > 0 then
			Duel.Draw(1 - tp, 1, REASON_EFFECT)
		end
	end
end

function s.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.searchcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_EXTRA, 0, 3, nil) and
			Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_EXTRA, 0, 3, 3, nil)
	Duel.Remove(g, POS_FACEDOWN, REASON_COST)
end
function s.thfilter(c)
	return c:IsSpell() and c:IsSetCard(0x192) and c:IsAbleToHand()
end
function s.searchtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.searchop(e, tp, eg, ep, ev, re, r, rp)
	local sg = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #sg > 0 then
		Duel.SendtoHand(sg, tp, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, sg)
	end
end

function s.retfilter(c)
	return c:IsCode(CARD_DREAMING_NEMLERIA) and c:IsFaceup()
end
function s.retfilter2(c)
	return c:IsCode(CARD_DREAMING_NEMLERIA) and c:IsFaceup() and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.retfilter, tp, LOCATION_EXTRA, 0, 2, nil) and
			Duel.IsExistingMatchingCard(s.retfilter2, tp, LOCATION_EXTRA, 0, 1, nil)
	end
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, s.retfilter2, tp, LOCATION_EXTRA, 0, 1, 1, nil)
	if #g > 0 then
		local th = g:GetFirst():IsAbleToHand()
		local td = g:GetFirst():IsAbleToDeck()
		local op = 0
		if th and td then
			op = Duel.SelectOption(tp, aux.Stringid(id, 3), aux.Stringid(id, 4))
		elseif th then
			op = 0
		else
			op = 1
		end
		if op == 0 then
			Duel.SendtoHand(g, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, g)
		else
			Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end
end