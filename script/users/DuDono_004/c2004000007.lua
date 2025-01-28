-- Nemleria Big Eepy
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
  -- reset Nemleria's bed
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,{id,0})
  e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
  -- omni-negate handtrap ?!
  local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

function s.sumfilter(c,e)
  return c:IsSetCard(SET_NEMLERIA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)>0 end
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	local nsh = Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
  if nsh > 9 and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    local maxs = nsh//10
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxs = 1 end
    local nc = Duel.SelectMatchingCard(tp,s.sumfilter,tp,0,LOCATION_ONFIELD,1,maxs,nil,e)
  end
end

function s.negfilter(c)
  return (c:IsFaceup() and not c:IsDisabled()) or c:IsType(TYPE_TRAPMONSTER)
end
function s.rmfilter(c)
  return c:IsFacedown() and c:IsAbleToRemove(POS_FACEDOWN)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,3,nil) and Duel.IsPlayerCanRemove(1-tp)
    and Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
  local c = e:GetHandler()
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,3,3,nil,1-tp,POS_FACEDOWN)
	if #sg == 3 then
		if Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT) then
      --negate a face-up card
      local nc = Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
      Duel.NegateRelatedChain(nc,RESET_TURN_SET)
      local e1=Effect.CreateEffect(c)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
      e1:SetCode(EFFECT_DISABLE)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      nc:RegisterEffect(e1)
      local e2=Effect.CreateEffect(c)
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
      e2:SetCode(EFFECT_DISABLE_EFFECT)
      e2:SetValue(RESET_TURN_SET)
      e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      nc:RegisterEffect(e2)
      if nc:IsType(TYPE_TRAPMONSTER) then
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        nc:RegisterEffect(e3)
      end
    end
	end
	Duel.ShuffleExtra(tp)
end