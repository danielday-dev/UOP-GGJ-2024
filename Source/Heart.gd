extends AnimatedSprite2D



func setAnimation(animation):
	if $Sprite.get_animation() != animation:
		$Sprite.play(animation)

func animationEnded():
	return $Sprite.frame_progress >= 1.0
