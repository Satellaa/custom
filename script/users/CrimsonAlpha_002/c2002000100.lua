 --CCG: Ritual Beast Ulti-Cannafalco
-- 1 Tuner + 1+ non-Tuner "Gusto" monsters, including at least 1 Synchro Monster
-- (This card is also treated as a "Gusto" card). Must either be Synchro Summoned, or Special 
-- Summoned (from your Extra Deck) by banishing 3 cards you control (1 "Ritual Beast Tamer", 1 "Spiritual Beast", 
-- and 1 "Ritual Beast Ulti-") If this card was Special Summoned from the Extra Deck, except with a card effect, this
-- card gains this effect.
-- ● When a monster(s) would be Summoned, OR an effect is activated that includes an effect that Summons a monster (Quick Effect): 
-- You can return 1 "Gusto" and/or "Ritual Beast" cards from your GY or among your banished cards to your Deck; negate the Summon, and if you do, destroy that monster(s).
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(Card.IsSetCard,0x10),1,99,nil,nil,nil,s.matfilter)
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x40b5),aux.FilterBoolFunctionEx(Card.IsSetCard,0x10b5),aux.FilterBoolFunctionEx(Card.IsSetCard,0x20b5))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true,aux.TRUE,1)
	-- Special Summon Proc
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetCode(EFFECT_SPSUMMON_PROC)
	-- e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	-- e2:SetRange(LOCATION_EXTRA)
	-- e2:SetValue(1)
	-- e2:SetCondition(s.SpCon)
	-- e2:SetTarget(s.SpTg)
	-- e2:SetOperation(s.SpOpe)
	-- c:RegisterEffect(e2)
	-- Negate Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.EffCon)
	e3:SetOperation(s.EffOpe)
	c:RegisterEffect(e3)
	--spsummon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GUSTO,SET_RITUAL_BEAST,SET_RITUAL_BEAST_TAMER,SET_SPIRITUAL_BEAST,SET_RITUAL_BEAST_ULTI}
-- {Synchro Material Check: ... including at least 1 Synchro Monster}
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil)
end
function s.cfilter(c)
	return c:IsType(TYPE_SYNCHRO)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
-- {Special Summon Proc: Pseudo-Contact Fusion}
-- function s.rescon(sg,e,tp,mg)
	-- return aux.ChkfMMZ(1)(sg,e,tp,mg) 
		-- and sg:IsExists(s.chk,1,nil,sg)
-- end
-- function s.chk(c,sg)
	-- return c:IsSetCard(SET_RITUAL_BEAST_ULTI) 
		-- and sg:IsExists(Card.IsSetCard,1,c,SET_RITUAL_BEAST_TAMER)
		-- and sg:IsExists(Card.IsSetCard,1,c,SET_SPIRITUAL_BEAST)
-- end
-- function s.spfilter1(c)
	-- return c:IsSetCard(SET_RITUAL_BEAST) 
		-- and c:IsAbleToRemoveAsCost()
-- end
-- function s.SpCon(e,c)
	-- if c==nil then return true end
	-- local tp=c:GetControler()
	-- local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_ONFIELD,0,nil)
	-- local g1=rg:Filter(Card.IsSetCard,nil,SET_RITUAL_BEAST_ULTI)
	-- local g2=rg:Filter(Card.IsSetCard,nil,SET_RITUAL_BEAST_TAMER)
	-- local g3=rg:Filter(Card.IsSetCard,nil,SET_SPIRITUAL_BEAST)
	-- local g=g1:Clone()
	-- g:Merge(g2)
	-- g:Merge(g3)
	-- return Duel.GetLocationCount(tp,LOCATION_ONFIELD)>-3 and #g1>0 and #g2>0 and #g3>0 and #g>2 
		-- and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
-- end
-- function s.SpTg(e,tp,eg,ep,ev,re,r,rp,c)
	-- local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	-- local g1=rg:Filter(Card.IsSetCard,nil,SET_RITUAL_BEAST_ULTI)
	-- local g2=rg:Filter(Card.IsSetCard,nil,SET_RITUAL_BEAST_TAMER)
	-- local g3=rg:Filter(Card.IsSetCard,nil,SET_SPIRITUAL_BEAST)
	-- g1:Merge(g2)
	-- g1:Merge(g3)
	-- local sg=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	-- if #sg>0 then
		-- sg:KeepAlive()
		-- e:SetLabelObject(sg)
		-- return true
	-- end
	-- return false
-- end
-- function s.SpOpe(e,tp,eg,ep,ev,re,r,rp,c)
	-- local g=e:GetLabelObject()
	-- if not g then return end
	-- Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- g:DeleteGroup()
-- end
-- {Effect Gain: Negate Summon}
function s.EffCon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
		or e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.EffOpe(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local r1=Effect.CreateEffect(c)
		r1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
		r1:SetDescription(aux.Stringid(id,0))
		r1:SetType(EFFECT_TYPE_QUICK_O)
		r1:SetRange(LOCATION_MZONE)
		r1:SetCode(EVENT_SPSUMMON)
		r1:SetCondition(s.NegCon)
		r1:SetCost(s.NegCost)
		r1:SetTarget(s.NegTarg)
		r1:SetOperation(s.NegOpe)
	c:RegisterEffect(r1)
	local r2=r1:Clone()
		r2:SetDescription(aux.Stringid(id,1))
		r2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(r2)
	local r3=r1:Clone()
		r3:SetDescription(aux.Stringid(id,2))
		r3:SetCode(EVENT_SUMMON)
	c:RegisterEffect(r3)
	-- Activate(effect)
	local r4=Effect.CreateEffect(c)
		r4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
		r4:SetType(EFFECT_TYPE_QUICK_O)
		r4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		r4:SetCode(EVENT_CHAINING)
		r4:SetRange(LOCATION_MZONE)
		r4:SetCountLimit(1)
		r4:SetCondition(s.NegCon2)
		r4:SetCost(s.NegCost)
		r4:SetTarget(s.NegTarg2)
		r4:SetOperation(s.NegOpe2)
	c:RegisterEffect(r4)
end
-- {Monster Effect: Negate Summon}
function s.NegCon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.costfilter(c)
	return c:IsSetCard({SET_GUSTO,SET_RITUAL_BEAST}) 
		and c:IsPublic()
		and c:IsAbleToDeckOrExtraAsCost()
end
function s.NegCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,nil) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE|LOCATION_GRAVE|LOCATION_REMOVED,0,2,2,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.NegTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function s.NegOpe(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
-- {Monster Effect: Negate Effect to Summon}
function s.NegCon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainNegatable(ev)
end
function s.NegTarg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.NegOpe2(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re))
		or Duel.Destroy(eg,REASON_EFFECT)<1 then return end
end