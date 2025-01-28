 --Apoqliphort Administrator
 --[ Pendulum Effect ]
 --You cannot Special Summon monsters, except for "Qli" monsters. This effect cannot be negated. If you have another "Qli" card in your other Pendulum Zone: You can destroy both cards in your Pendulum Zones, and if you do, add 1 "Qli" card from your Deck or GY, except "Apoqliphort Administrator".
 ----------------------------------------
--[ Monster Effect ]
--You can Ritual Summon this card using "Apoqliphort Advent". Must either be Ritual Summoned, or Special Summoned (from your face-up Extra Deck) by Tributing 3 "Qli" monsters. You can only Special Summon "Apoqliphort Administrator(s)" once per turn. Unaffected by other card's effects. (Quick Effect): You can place this card in your opponent's Pendulum Zone, but destroy it during the End Phase. If this card on the field is destroyed by battle or card effect: You can Special Summon 1 "Qliphort Genius" from your Extra Deck to the Extra Monster Zone. (This is treated as a Link Summon.)
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	c:SetSPSummonOnce(id)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--pendlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)	
	--special summon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(s.ritlimit)
	c:RegisterEffect(e3)
	--special summon proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--summon qliphort genius
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.sscon)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
	--pendulum set
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.pctg)
	e5:SetOperation(s.pcop)
	c:RegisterEffect(e5)
end
s.listed_series={0xaa}
s.listed_names={22423493}
-- {Special Summon Restriction: Qli}
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xaa)
end
-- {Pendulum Effect: Search}
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xaa)
end
function s.filter(c)
	return c:IsSetCard(0xaa) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #dg<2 then return end
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
-- {Special Summon Limit: Only from hand and Extra Deck}
function s.ritlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
-- {Special Summon Proc: Summon from the Extra Deck}
function s.chk(c,sg)
	return c:IsSetCard(0xaa)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) 
		and sg:IsExists(s.chk,1,nil,sg)
		and (not e:GetHandler():IsLocation(LOCATION_EXTRA) or Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0)
end
function s.hspfilter(c,e,tp)
	return c:IsSetCard(0xaa) and c:IsFaceup() 
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg>2
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,nil)
	local mg1=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #mg1>2 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
-- {Monster Effect: Immunity}
function s.econ(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--{Monster Effect: Special Summon 'Qliphort Genius'}
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) 
end
function s.ssfilter(c,e,tp)
	return c:IsCode(22423493) 
	   and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_FORCE_MZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(96)
		Duel.RegisterEffect(e1,tp)
		local res=Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0
			and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		e1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(96)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCountFromEx(tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
		end
	end
	e1:Reset() 
end
--{Monster Effect: Place in Pendulum Zone}
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(1-tp,LOCATION_PZONE,0) or Duel.CheckLocation(1-tp,LOCATION_PZONE,1)) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckLocation(1-tp,LOCATION_PZONE,0) and not Duel.CheckLocation(1-tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(c,tp,1-tp,LOCATION_PZONE,POS_FACEUP,true)
	local fid=e:GetHandler():GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1,fid)
	local r1=Effect.CreateEffect(e:GetHandler())
		r1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		r1:SetCode(EVENT_PHASE+PHASE_END)
		r1:SetCountLimit(1)
		r1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		r1:SetLabel(fid)
		r1:SetLabelObject(c)
		r1:SetCondition(s.descon)
		r1:SetOperation(s.desop)
	Duel.RegisterEffect(r1,tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end