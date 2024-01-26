extends AnimatedSprite2D



func setAnimation(animation):
	if self.get_animation() != animation:
		self.play(animation)

func animationEnded():
	return self.frame_progress >= 1.0
