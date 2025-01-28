--Resolve of Zefra
Duel.LoadScript("_load_.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_ZEFRA))
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Cannot be destroyed by the opponent's card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--spsummon
	local params={nil,nil,s.extrafil,s.extraop,s.forcedmat}
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.fcond)
	e4:SetCountLimit(1,id)
	e4:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e4:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e4)
end
s.listed_series={SET_ZEFRA}
function s.atkval(e,c)
	local tp=e:GetHandler():GetOwner()
	local val=aux.GetPendulumScaleSum(tp) + aux.GetPendulumScaleSum(1-tp)
	return val*100
end
function s.fcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():IsControler(tp)
end
function s.forcedmat(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():GetEquipTarget()
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA|LOCATION_REMOVED)<=1
end
function s.extrafil(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_ZEFRA) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA|LOCATION_REMOVED,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA|LOCATION_REMOVED) and c:IsMonster() and c:IsPublic() 
		and c:IsSetCard(SET_ZEFRA) and c:IsAbleToHand()
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.exfilter,nil)
	if #rg>0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_ZEFRA) then
		Duel.SendtoHand(rg,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end