Duel.GetFusionMaterial=(function()
	local oldfunc=Duel.GetFusionMaterial
	return function(tp)
		local res=oldfunc(tp)
		local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_EXTRA|LOCATION_DECK,0,nil,EFFECT_EXTRA_FUSION_MATERIAL)
		if #g>0 then
			res:Merge(g)
		end
		return res
	end
end)()