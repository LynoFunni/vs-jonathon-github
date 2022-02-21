local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then --Block the first countdown
		startVideo('Vs_Jonathon_Cutscene_2');
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end