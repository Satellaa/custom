Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Destroy cards in column
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	
	--Banish to change position and negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={0x77b}

function s.desfilter(c)
	return not (c:IsSetCard(0x77b) and c:IsMonster())
end

function s.colcheck(g)
	return g:IsExists(s.desfilter,1,nil)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local cg=c:GetColumnGroup()
		-- Check if there's at least one valid target in the column (excluding this card)
		return cg:IsExists(s.desfilter,1,c)
	end
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	local g=cg:Filter(s.desfilter,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	local g=cg:Filter(s.desfilter,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.posfilter(c)
	return c:IsSetCard(0x77b) and c:IsFaceup() and c:IsCanChangePosition() and c:IsPosition(POS_FACEUP_ATTACK)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_MZONE,1,nil) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g1=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g2=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_MZONE,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsControler(tp) and tc1:IsFaceup() then
		if Duel.ChangePosition(tc1,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
			and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e2)
		end
	end
end