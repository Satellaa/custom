-- Night Night, Nemleria
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
  -- activate, put Nemleria to sleep and Set a Spell/Trap
  local e1 = Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,{id,0})
  e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  -- GY effect, summon from banish (will likely not work)
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.stfilter(c)
  return c:IsSetCard(0x192) and c:IsSpellTrap() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and
  Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26237713,0))
	local g=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoExtraP(g,tp,REASON_EFFECT)
	end
  Duel.BreakEffect()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
  Duel.SSet(tp,tc)
end

function s.spfilter(c)
  return c:IsFacedown() and not c:IsHasEffect(EFFECT_SPSUMMON_CONDITION) and c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,70155677) and
    Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) 
  end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
    local c=g:GetFirst()
		Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,false,true,POS_FACEUP)
    local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(47132793,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
	end
end