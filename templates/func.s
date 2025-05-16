# Full stack frame (Facooya convention)
func_full:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	# epil
	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	pop %bp
	ret

# Callee-saved stack frame (Facooya convention)
func_callee:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# epil
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
