-- Nemleria's Bedroom
Duel.LoadScript("_load_.lua")
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)
  -- excavate if eepy girl is eepy
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_FZONE)
  e2:SetCountLimit(1,{id,0})
  e2:SetTarget(s.extg)
  e2:SetOperation(s.exop)
  c:RegisterEffect(e2)
  -- grab back from GY
  local e3 = Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_FZONE)
  e3:SetCountLimit(1,{id,1})
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
end
s.listed_series={SET_NEMLERIA}
s.listed_names={CARD_DREAMING_NEMLERIA}

function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct = Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_REMOVED,0,nil)
  if chk == 0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DREAMING_NEMLERIA),tp,LOCATION_EXTRA,0,1,nil)
    and ct > 1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) > ct//2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
  Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.exfilter(c,e,tp)
  return c:IsSetCard(SET_NEMLERIA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
  local ct = Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_REMOVED,0,nil)
  if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,ct//2)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  local g=Duel.GetDecktopGroup(tp,ct//2):Filter(s.exfilter,nil,e,tp,e,tp)
  local sc = 0
  if #g>0 then
    local ms = math.max(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,ms,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
  Duel.ShuffleDeck(tp)
end


function s.thbanishfilter(c)
  return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and not c:IsCode(CARD_DREAMING_NEMLERIA)
end
function s.thfilter(c)
  return c:IsSetCard(SET_NEMLERIA) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk == 0 then return Duel.GetMatchingGroupCount(s.thbanishfilter,tp,LOCATION_EXTRA,0,nil)>=2 and 
    Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
  end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.thbanishfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end