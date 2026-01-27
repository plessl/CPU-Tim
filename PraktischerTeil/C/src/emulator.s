./emulator:	file format mach-o arm64

Disassembly of section __TEXT,__text:

00000001000005e8 <_fetch>:
1000005e8: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
1000005ec: 91001108    	add	x8, x8, #0x4
1000005f0: 8b20c108    	add	x8, x8, w0, sxtw
1000005f4: b9400900    	ldr	w0, [x8, #0x8]
1000005f8: d65f03c0    	ret

00000001000005fc <_decodeAndExecute>:
1000005fc: d10143ff    	sub	sp, sp, #0x50
100000600: a9015ff8    	stp	x24, x23, [sp, #0x10]
100000604: a90257f6    	stp	x22, x21, [sp, #0x20]
100000608: a9034ff4    	stp	x20, x19, [sp, #0x30]
10000060c: a9047bfd    	stp	x29, x30, [sp, #0x40]
100000610: 910103fd    	add	x29, sp, #0x40
100000614: 12001808    	and	w8, w0, #0x7f
100000618: 7100d91f    	cmp	w8, #0x36
10000061c: 5400082c    	b.gt	0x100000720 <_decodeAndExecute+0x124>
100000620: 7100591f    	cmp	w8, #0x16
100000624: 54000a4d    	b.le	0x10000076c <_decodeAndExecute+0x170>
100000628: 71005d1f    	cmp	w8, #0x17
10000062c: 54002280    	b.eq	0x100000a7c <_decodeAndExecute+0x480>
100000630: 71008d1f    	cmp	w8, #0x23
100000634: 54002a20    	b.eq	0x100000b78 <_decodeAndExecute+0x57c>
100000638: 7100cd1f    	cmp	w8, #0x33
10000063c: 54006861    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000640: 53072c13    	ubfx	w19, w0, #7, #5
100000644: 530c3817    	ubfx	w23, w0, #12, #3
100000648: 530f4c15    	ubfx	w21, w0, #15, #5
10000064c: 53146014    	ubfx	w20, w0, #20, #5
100000650: 53197c16    	lsr	w22, w0, #25
100000654: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000658: 39400108    	ldrb	w8, [x8]
10000065c: 7100051f    	cmp	w8, #0x1
100000660: 540002a1    	b.ne	0x1000006b4 <_decodeAndExecute+0xb8>
100000664: f90003f3    	str	x19, [sp]
100000668: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000066c: 91275000    	add	x0, x0, #0x9d4
100000670: 940004cd    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000674: f90003f7    	str	x23, [sp]
100000678: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000067c: 91277800    	add	x0, x0, #0x9de
100000680: 940004c9    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000684: f90003f5    	str	x21, [sp]
100000688: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000068c: 9127ac00    	add	x0, x0, #0x9eb
100000690: 940004c5    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000694: f90003f4    	str	x20, [sp]
100000698: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000069c: 9127d800    	add	x0, x0, #0x9f6
1000006a0: 940004c1    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000006a4: f90003f6    	str	x22, [sp]
1000006a8: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000006ac: 91280400    	add	x0, x0, #0xa01
1000006b0: 940004bd    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000006b4: 71000eff    	cmp	w23, #0x3
1000006b8: 5400354c    	b.gt	0x100000d60 <_decodeAndExecute+0x764>
1000006bc: 710006ff    	cmp	w23, #0x1
1000006c0: 540042cc    	b.gt	0x100000f18 <_decodeAndExecute+0x91c>
1000006c4: 350064f7    	cbnz	w23, 0x100001360 <_decodeAndExecute+0xd64>
1000006c8: 710082df    	cmp	w22, #0x20
1000006cc: 540079a0    	b.eq	0x100001600 <_decodeAndExecute+0x1004>
1000006d0: 350063d6    	cbnz	w22, 0x100001348 <_decodeAndExecute+0xd4c>
1000006d4: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
1000006d8: 91001108    	add	x8, x8, #0x4
1000006dc: 52900109    	mov	w9, #0x8008             ; =32776
1000006e0: 8b090109    	add	x9, x8, x9
1000006e4: b875592a    	ldr	w10, [x9, w21, uxtw #2]
1000006e8: b874592b    	ldr	w11, [x9, w20, uxtw #2]
1000006ec: 0b0a016a    	add	w10, w11, w10
1000006f0: b833592a    	str	w10, [x9, w19, uxtw #2]
1000006f4: b9400109    	ldr	w9, [x8]
1000006f8: 11001129    	add	w9, w9, #0x4
1000006fc: b9000109    	str	w9, [x8]
100000700: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000704: 91320000    	add	x0, x0, #0xc80
100000708: a9447bfd    	ldp	x29, x30, [sp, #0x40]
10000070c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000710: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000714: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000718: 910143ff    	add	sp, sp, #0x50
10000071c: 140004a8    	b	0x1000019bc <_scanf+0x1000019bc>
100000720: 7101991f    	cmp	w8, #0x66
100000724: 540009ad    	b.le	0x100000858 <_decodeAndExecute+0x25c>
100000728: 71019d1f    	cmp	w8, #0x67
10000072c: 54001d00    	b.eq	0x100000acc <_decodeAndExecute+0x4d0>
100000730: 7101bd1f    	cmp	w8, #0x6f
100000734: 54002840    	b.eq	0x100000c3c <_decodeAndExecute+0x640>
100000738: 7101cd1f    	cmp	w8, #0x73
10000073c: 54006061    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000740: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000744: 912d6400    	add	x0, x0, #0xb59
100000748: 9400049d    	bl	0x1000019bc <_scanf+0x1000019bc>
10000074c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000750: 912db400    	add	x0, x0, #0xb6d
100000754: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000758: a9434ff4    	ldp	x20, x19, [sp, #0x30]
10000075c: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000760: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000764: 910143ff    	add	sp, sp, #0x50
100000768: 14000495    	b	0x1000019bc <_scanf+0x1000019bc>
10000076c: 71000d1f    	cmp	w8, #0x3
100000770: 54000e20    	b.eq	0x100000934 <_decodeAndExecute+0x338>
100000774: 71004d1f    	cmp	w8, #0x13
100000778: 54005e81    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
10000077c: 53072c13    	ubfx	w19, w0, #7, #5
100000780: 530c3816    	ubfx	w22, w0, #12, #3
100000784: 530f4c14    	ubfx	w20, w0, #15, #5
100000788: 13147c15    	asr	w21, w0, #20
10000078c: 13197c17    	asr	w23, w0, #25
100000790: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000794: 39400108    	ldrb	w8, [x8]
100000798: 7100051f    	cmp	w8, #0x1
10000079c: 54000301    	b.ne	0x1000007fc <_decodeAndExecute+0x200>
1000007a0: f90003f3    	str	x19, [sp]
1000007a4: b0000008    	adrp	x8, 0x100001000 <_decodeAndExecute+0xa04>
1000007a8: 91275108    	add	x8, x8, #0x9d4
1000007ac: aa0003f8    	mov	x24, x0
1000007b0: aa0803e0    	mov	x0, x8
1000007b4: 9400047c    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000007b8: f90003f6    	str	x22, [sp]
1000007bc: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000007c0: 91277800    	add	x0, x0, #0x9de
1000007c4: 94000478    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000007c8: f90003f4    	str	x20, [sp]
1000007cc: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000007d0: 9127ac00    	add	x0, x0, #0x9eb
1000007d4: 94000474    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000007d8: f90003f5    	str	x21, [sp]
1000007dc: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000007e0: 91283800    	add	x0, x0, #0xa0e
1000007e4: 94000470    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000007e8: f90003f7    	str	x23, [sp]
1000007ec: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000007f0: 91286000    	add	x0, x0, #0xa18
1000007f4: 9400046c    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000007f8: aa1803e0    	mov	x0, x24
1000007fc: 71000edf    	cmp	w22, #0x3
100000800: 5400272c    	b.gt	0x100000ce4 <_decodeAndExecute+0x6e8>
100000804: 710006df    	cmp	w22, #0x1
100000808: 540030cc    	b.gt	0x100000e20 <_decodeAndExecute+0x824>
10000080c: 35005276    	cbnz	w22, 0x100001258 <_decodeAndExecute+0xc5c>
100000810: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000814: 91001108    	add	x8, x8, #0x4
100000818: 52900109    	mov	w9, #0x8008             ; =32776
10000081c: 8b090109    	add	x9, x8, x9
100000820: b874592a    	ldr	w10, [x9, w20, uxtw #2]
100000824: 0b15014a    	add	w10, w10, w21
100000828: b833592a    	str	w10, [x9, w19, uxtw #2]
10000082c: b9400109    	ldr	w9, [x8]
100000830: 11001129    	add	w9, w9, #0x4
100000834: b9000109    	str	w9, [x8]
100000838: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000083c: 91315c00    	add	x0, x0, #0xc57
100000840: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000844: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000848: a94257f6    	ldp	x22, x21, [sp, #0x20]
10000084c: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000850: 910143ff    	add	sp, sp, #0x50
100000854: 1400045a    	b	0x1000019bc <_scanf+0x1000019bc>
100000858: 7100dd1f    	cmp	w8, #0x37
10000085c: 54000da0    	b.eq	0x100000a10 <_decodeAndExecute+0x414>
100000860: 71018d1f    	cmp	w8, #0x63
100000864: 54005721    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000868: 53077c08    	lsr	w8, w0, #7
10000086c: 530c3816    	ubfx	w22, w0, #12, #3
100000870: 530f4c15    	ubfx	w21, w0, #15, #5
100000874: 53147c09    	lsr	w9, w0, #20
100000878: 53146014    	ubfx	w20, w0, #20, #5
10000087c: 53137c0a    	lsr	w10, w0, #19
100000880: 1214014a    	and	w10, w10, #0x1000
100000884: 121b1529    	and	w9, w9, #0x7e0
100000888: 121f0d0b    	and	w11, w8, #0x1e
10000088c: 3315010a    	bfi	w10, w8, #11, #1
100000890: 2a0b0128    	orr	w8, w9, w11
100000894: 2a080148    	orr	w8, w10, w8
100000898: 13003113    	sbfx	w19, w8, #0, #13
10000089c: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
1000008a0: 39400108    	ldrb	w8, [x8]
1000008a4: 7100051f    	cmp	w8, #0x1
1000008a8: 54000221    	b.ne	0x1000008ec <_decodeAndExecute+0x2f0>
1000008ac: f90003f6    	str	x22, [sp]
1000008b0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000008b4: 91277800    	add	x0, x0, #0x9de
1000008b8: 9400043b    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000008bc: f90003f5    	str	x21, [sp]
1000008c0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000008c4: 9127ac00    	add	x0, x0, #0x9eb
1000008c8: 94000437    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000008cc: f90003f4    	str	x20, [sp]
1000008d0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000008d4: 9127d800    	add	x0, x0, #0x9f6
1000008d8: 94000433    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000008dc: f90003f3    	str	x19, [sp]
1000008e0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000008e4: 91283800    	add	x0, x0, #0xa0e
1000008e8: 9400042f    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000008ec: 710012df    	cmp	w22, #0x4
1000008f0: 5400210c    	b.gt	0x100000d10 <_decodeAndExecute+0x714>
1000008f4: 340044f6    	cbz	w22, 0x100001190 <_decodeAndExecute+0xb94>
1000008f8: 710006df    	cmp	w22, #0x1
1000008fc: 540047c0    	b.eq	0x1000011f4 <_decodeAndExecute+0xbf8>
100000900: 710012df    	cmp	w22, #0x4
100000904: 54005221    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000908: 90000056    	adrp	x22, 0x100008000 <_show_instruction>
10000090c: 910012d6    	add	x22, x22, #0x4
100000910: 52900108    	mov	w8, #0x8008             ; =32776
100000914: 8b0802c8    	add	x8, x22, x8
100000918: b8755909    	ldr	w9, [x8, w21, uxtw #2]
10000091c: b8745908    	ldr	w8, [x8, w20, uxtw #2]
100000920: 6b08013f    	cmp	w9, w8
100000924: 54005e0a    	b.ge	0x1000014e4 <_decodeAndExecute+0xee8>
100000928: b94002c8    	ldr	w8, [x22]
10000092c: 0b130108    	add	w8, w8, w19
100000930: 140002f2    	b	0x1000014f8 <_decodeAndExecute+0xefc>
100000934: 53072c13    	ubfx	w19, w0, #7, #5
100000938: 530c3815    	ubfx	w21, w0, #12, #3
10000093c: 530f4c14    	ubfx	w20, w0, #15, #5
100000940: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000944: 39400108    	ldrb	w8, [x8]
100000948: 7100051f    	cmp	w8, #0x1
10000094c: 540002a1    	b.ne	0x1000009a0 <_decodeAndExecute+0x3a4>
100000950: 13147c17    	asr	w23, w0, #20
100000954: f90003f3    	str	x19, [sp]
100000958: b0000008    	adrp	x8, 0x100001000 <_decodeAndExecute+0xa04>
10000095c: 91275108    	add	x8, x8, #0x9d4
100000960: aa0003f6    	mov	x22, x0
100000964: aa0803e0    	mov	x0, x8
100000968: 9400040f    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000096c: f90003f5    	str	x21, [sp]
100000970: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000974: 91277800    	add	x0, x0, #0x9de
100000978: 9400040b    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000097c: f90003f4    	str	x20, [sp]
100000980: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000984: 9127ac00    	add	x0, x0, #0x9eb
100000988: 94000407    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000098c: f90003f7    	str	x23, [sp]
100000990: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000994: 91283800    	add	x0, x0, #0xa0e
100000998: 94000403    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000099c: aa1603e0    	mov	x0, x22
1000009a0: 710006bf    	cmp	w21, #0x1
1000009a4: 540020cd    	b.le	0x100000dbc <_decodeAndExecute+0x7c0>
1000009a8: 71000abf    	cmp	w21, #0x2
1000009ac: 540035c0    	b.eq	0x100001064 <_decodeAndExecute+0xa68>
1000009b0: 710012bf    	cmp	w21, #0x4
1000009b4: 540038c0    	b.eq	0x1000010cc <_decodeAndExecute+0xad0>
1000009b8: 710016bf    	cmp	w21, #0x5
1000009bc: 54004c61    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
1000009c0: 90000055    	adrp	x21, 0x100008000 <_show_instruction>
1000009c4: 910012b5    	add	x21, x21, #0x4
1000009c8: 8b344aa8    	add	x8, x21, w20, uxtw #2
1000009cc: 52900109    	mov	w9, #0x8008             ; =32776
1000009d0: b8696908    	ldr	w8, [x8, x9]
1000009d4: 0b805108    	add	w8, w8, w0, asr #20
1000009d8: 11000509    	add	w9, w8, #0x1
1000009dc: 530e7d2a    	lsr	w10, w9, #14
1000009e0: 3500398a    	cbnz	w10, 0x100001110 <_decodeAndExecute+0xb14>
1000009e4: 5288010a    	mov	w10, #0x4008            ; =16392
1000009e8: 8b0a02aa    	add	x10, x21, x10
1000009ec: 38684948    	ldrb	w8, [x10, w8, uxtw]
1000009f0: 38694949    	ldrb	w9, [x10, w9, uxtw]
1000009f4: 2a092108    	orr	w8, w8, w9, lsl #8
1000009f8: 8b334aa9    	add	x9, x21, w19, uxtw #2
1000009fc: 5290010a    	mov	w10, #0x8008            ; =32776
100000a00: b82a6928    	str	w8, [x9, x10]
100000a04: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000a08: 912fac00    	add	x0, x0, #0xbeb
100000a0c: 140001d7    	b	0x100001168 <_decodeAndExecute+0xb6c>
100000a10: 53072c14    	ubfx	w20, w0, #7, #5
100000a14: 12144c13    	and	w19, w0, #0xfffff000
100000a18: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000a1c: 39400108    	ldrb	w8, [x8]
100000a20: 7100051f    	cmp	w8, #0x1
100000a24: 54000121    	b.ne	0x100000a48 <_decodeAndExecute+0x44c>
100000a28: f90003f4    	str	x20, [sp]
100000a2c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000a30: 91275000    	add	x0, x0, #0x9d4
100000a34: 940003dc    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000a38: f90003f3    	str	x19, [sp]
100000a3c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000a40: 91283800    	add	x0, x0, #0xa0e
100000a44: 940003d8    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000a48: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000a4c: 91001108    	add	x8, x8, #0x4
100000a50: 8b140908    	add	x8, x8, x20, lsl #2
100000a54: 52900109    	mov	w9, #0x8008             ; =32776
100000a58: b8296913    	str	w19, [x8, x9]
100000a5c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000a60: 912e0000    	add	x0, x0, #0xb80
100000a64: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000a68: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000a6c: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000a70: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000a74: 910143ff    	add	sp, sp, #0x50
100000a78: 140003d1    	b	0x1000019bc <_scanf+0x1000019bc>
100000a7c: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000a80: 39400108    	ldrb	w8, [x8]
100000a84: 7100051f    	cmp	w8, #0x1
100000a88: 54000121    	b.ne	0x100000aac <_decodeAndExecute+0x4b0>
100000a8c: 53072c08    	ubfx	w8, w0, #7, #5
100000a90: f90003e8    	str	x8, [sp]
100000a94: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000a98: 91275000    	add	x0, x0, #0x9d4
100000a9c: 940003c2    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000aa0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000aa4: 91283800    	add	x0, x0, #0xa0e
100000aa8: 940003bf    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000aac: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000ab0: 912de800    	add	x0, x0, #0xb7a
100000ab4: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000ab8: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000abc: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000ac0: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000ac4: 910143ff    	add	sp, sp, #0x50
100000ac8: 140003bd    	b	0x1000019bc <_scanf+0x1000019bc>
100000acc: 53072c13    	ubfx	w19, w0, #7, #5
100000ad0: 530f4c14    	ubfx	w20, w0, #15, #5
100000ad4: 13147c08    	asr	w8, w0, #20
100000ad8: 121f3915    	and	w21, w8, #0xfffe
100000adc: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000ae0: 39400108    	ldrb	w8, [x8]
100000ae4: 7100051f    	cmp	w8, #0x1
100000ae8: 54000241    	b.ne	0x100000b30 <_decodeAndExecute+0x534>
100000aec: 530c3816    	ubfx	w22, w0, #12, #3
100000af0: f90003f3    	str	x19, [sp]
100000af4: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000af8: 91275000    	add	x0, x0, #0x9d4
100000afc: 940003aa    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000b00: f90003f6    	str	x22, [sp]
100000b04: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000b08: 91277800    	add	x0, x0, #0x9de
100000b0c: 940003a6    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000b10: f90003f4    	str	x20, [sp]
100000b14: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000b18: 9127ac00    	add	x0, x0, #0x9eb
100000b1c: 940003a2    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000b20: f90003f5    	str	x21, [sp]
100000b24: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000b28: 91283800    	add	x0, x0, #0xa0e
100000b2c: 9400039e    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000b30: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000b34: 91001108    	add	x8, x8, #0x4
100000b38: b9400109    	ldr	w9, [x8]
100000b3c: 11001129    	add	w9, w9, #0x4
100000b40: 5290010a    	mov	w10, #0x8008            ; =32776
100000b44: 8b0a010a    	add	x10, x8, x10
100000b48: b8337949    	str	w9, [x10, x19, lsl #2]
100000b4c: b8747949    	ldr	w9, [x10, x20, lsl #2]
100000b50: 0b150129    	add	w9, w9, w21
100000b54: b9000109    	str	w9, [x8]
100000b58: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000b5c: 912e1000    	add	x0, x0, #0xb84
100000b60: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000b64: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000b68: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000b6c: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000b70: 910143ff    	add	sp, sp, #0x50
100000b74: 14000392    	b	0x1000019bc <_scanf+0x1000019bc>
100000b78: 53077c08    	lsr	w8, w0, #7
100000b7c: 530c3816    	ubfx	w22, w0, #12, #3
100000b80: 530f4c15    	ubfx	w21, w0, #15, #5
100000b84: 53146013    	ubfx	w19, w0, #20, #5
100000b88: 12071809    	and	w9, w0, #0xfe000000
100000b8c: 330c1109    	bfi	w9, w8, #20, #5
100000b90: 13147d34    	asr	w20, w9, #20
100000b94: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000b98: 39400108    	ldrb	w8, [x8]
100000b9c: 7100051f    	cmp	w8, #0x1
100000ba0: 54000221    	b.ne	0x100000be4 <_decodeAndExecute+0x5e8>
100000ba4: f90003f6    	str	x22, [sp]
100000ba8: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000bac: 91277800    	add	x0, x0, #0x9de
100000bb0: 9400037d    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000bb4: f90003f5    	str	x21, [sp]
100000bb8: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000bbc: 9127ac00    	add	x0, x0, #0x9eb
100000bc0: 94000379    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000bc4: f90003f3    	str	x19, [sp]
100000bc8: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000bcc: 9127d800    	add	x0, x0, #0x9f6
100000bd0: 94000375    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000bd4: f90003f4    	str	x20, [sp]
100000bd8: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000bdc: 91283800    	add	x0, x0, #0xa0e
100000be0: 94000371    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000be4: 71000adf    	cmp	w22, #0x2
100000be8: 54001c40    	b.eq	0x100000f70 <_decodeAndExecute+0x974>
100000bec: 710006df    	cmp	w22, #0x1
100000bf0: 540016a0    	b.eq	0x100000ec4 <_decodeAndExecute+0x8c8>
100000bf4: 35003ab6    	cbnz	w22, 0x100001348 <_decodeAndExecute+0xd4c>
100000bf8: 90000056    	adrp	x22, 0x100008000 <_show_instruction>
100000bfc: 910012d6    	add	x22, x22, #0x4
100000c00: 8b354ac8    	add	x8, x22, w21, uxtw #2
100000c04: 52900109    	mov	w9, #0x8008             ; =32776
100000c08: b8696908    	ldr	w8, [x8, x9]
100000c0c: 0b140108    	add	w8, w8, w20
100000c10: 530e7d09    	lsr	w9, w8, #14
100000c14: 35001e69    	cbnz	w9, 0x100000fe0 <_decodeAndExecute+0x9e4>
100000c18: 8b334ac9    	add	x9, x22, w19, uxtw #2
100000c1c: 5290010a    	mov	w10, #0x8008            ; =32776
100000c20: b86a6929    	ldr	w9, [x9, x10]
100000c24: 8b2842c8    	add	x8, x22, w8, uxtw
100000c28: 5288010a    	mov	w10, #0x4008            ; =16392
100000c2c: 382a6909    	strb	w9, [x8, x10]
100000c30: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000c34: 912fa000    	add	x0, x0, #0xbe8
100000c38: 140000ec    	b	0x100000fe8 <_decodeAndExecute+0x9ec>
100000c3c: 53072c13    	ubfx	w19, w0, #7, #5
100000c40: 53147c08    	lsr	w8, w0, #20
100000c44: 121f2508    	and	w8, w8, #0x7fe
100000c48: 53097c09    	lsr	w9, w0, #9
100000c4c: 12150129    	and	w9, w9, #0x800
100000c50: 12141c0a    	and	w10, w0, #0xff000
100000c54: 2a0a0129    	orr	w9, w9, w10
100000c58: 2a080128    	orr	w8, w9, w8
100000c5c: 52a00209    	mov	w9, #0x100000           ; =1048576
100000c60: 6a402d29    	ands	w9, w9, w0, lsr #11
100000c64: 2a080129    	orr	w9, w9, w8
100000c68: 320b2929    	orr	w9, w9, #0xffe00000
100000c6c: 1a890114    	csel	w20, w8, w9, eq
100000c70: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000c74: 39400108    	ldrb	w8, [x8]
100000c78: 7100051f    	cmp	w8, #0x1
100000c7c: 54000121    	b.ne	0x100000ca0 <_decodeAndExecute+0x6a4>
100000c80: f90003f3    	str	x19, [sp]
100000c84: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000c88: 91275000    	add	x0, x0, #0x9d4
100000c8c: 94000346    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000c90: f90003f4    	str	x20, [sp]
100000c94: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000c98: 91283800    	add	x0, x0, #0xa0e
100000c9c: 94000342    	bl	0x1000019a4 <_scanf+0x1000019a4>
100000ca0: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000ca4: 91001108    	add	x8, x8, #0x4
100000ca8: b9400109    	ldr	w9, [x8]
100000cac: 1100112a    	add	w10, w9, #0x4
100000cb0: 8b13090b    	add	x11, x8, x19, lsl #2
100000cb4: 5290010c    	mov	w12, #0x8008            ; =32776
100000cb8: b82c696a    	str	w10, [x11, x12]
100000cbc: 0b140129    	add	w9, w9, w20
100000cc0: b9000109    	str	w9, [x8]
100000cc4: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000cc8: 912e2400    	add	x0, x0, #0xb89
100000ccc: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000cd0: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000cd4: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000cd8: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000cdc: 910143ff    	add	sp, sp, #0x50
100000ce0: 14000337    	b	0x1000019bc <_scanf+0x1000019bc>
100000ce4: 710016df    	cmp	w22, #0x5
100000ce8: 54000c6c    	b.gt	0x100000e74 <_decodeAndExecute+0x878>
100000cec: 710012df    	cmp	w22, #0x4
100000cf0: 54002da1    	b.ne	0x1000012a4 <_decodeAndExecute+0xca8>
100000cf4: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000cf8: 91001108    	add	x8, x8, #0x4
100000cfc: 52900109    	mov	w9, #0x8008             ; =32776
100000d00: 8b090109    	add	x9, x8, x9
100000d04: b874592a    	ldr	w10, [x9, w20, uxtw #2]
100000d08: 4a15014a    	eor	w10, w10, w21
100000d0c: 1400018b    	b	0x100001338 <_decodeAndExecute+0xd3c>
100000d10: 710016df    	cmp	w22, #0x5
100000d14: 54002540    	b.eq	0x1000011bc <_decodeAndExecute+0xbc0>
100000d18: 71001adf    	cmp	w22, #0x6
100000d1c: 54002880    	b.eq	0x10000122c <_decodeAndExecute+0xc30>
100000d20: 71001edf    	cmp	w22, #0x7
100000d24: 54003121    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000d28: 90000056    	adrp	x22, 0x100008000 <_show_instruction>
100000d2c: 910012d6    	add	x22, x22, #0x4
100000d30: 52900108    	mov	w8, #0x8008             ; =32776
100000d34: 8b0802c8    	add	x8, x22, x8
100000d38: b8755909    	ldr	w9, [x8, w21, uxtw #2]
100000d3c: b8745908    	ldr	w8, [x8, w20, uxtw #2]
100000d40: 6b08013f    	cmp	w9, w8
100000d44: 54003ec2    	b.hs	0x10000151c <_decodeAndExecute+0xf20>
100000d48: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000d4c: 912e8c00    	add	x0, x0, #0xba3
100000d50: 9400031b    	bl	0x1000019bc <_scanf+0x1000019bc>
100000d54: b94002c8    	ldr	w8, [x22]
100000d58: 11001108    	add	w8, w8, #0x4
100000d5c: 140001f2    	b	0x100001524 <_decodeAndExecute+0xf28>
100000d60: 710016ff    	cmp	w23, #0x5
100000d64: 5400156c    	b.gt	0x100001010 <_decodeAndExecute+0xa14>
100000d68: 710012ff    	cmp	w23, #0x4
100000d6c: 54003201    	b.ne	0x1000013ac <_decodeAndExecute+0xdb0>
100000d70: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000d74: 91001108    	add	x8, x8, #0x4
100000d78: 52900109    	mov	w9, #0x8008             ; =32776
100000d7c: 8b090109    	add	x9, x8, x9
100000d80: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100000d84: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100000d88: 4a0a016a    	eor	w10, w11, w10
100000d8c: b833592a    	str	w10, [x9, w19, uxtw #2]
100000d90: b9400109    	ldr	w9, [x8]
100000d94: 11001129    	add	w9, w9, #0x4
100000d98: b9000109    	str	w9, [x8]
100000d9c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000da0: 9131d000    	add	x0, x0, #0xc74
100000da4: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000da8: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000dac: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000db0: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000db4: 910143ff    	add	sp, sp, #0x50
100000db8: 14000301    	b	0x1000019bc <_scanf+0x1000019bc>
100000dbc: 34001b15    	cbz	w21, 0x10000111c <_decodeAndExecute+0xb20>
100000dc0: 710006bf    	cmp	w21, #0x1
100000dc4: 54002c21    	b.ne	0x100001348 <_decodeAndExecute+0xd4c>
100000dc8: 90000055    	adrp	x21, 0x100008000 <_show_instruction>
100000dcc: 910012b5    	add	x21, x21, #0x4
100000dd0: 8b344aa8    	add	x8, x21, w20, uxtw #2
100000dd4: 52900109    	mov	w9, #0x8008             ; =32776
100000dd8: b8696908    	ldr	w8, [x8, x9]
100000ddc: 0b805108    	add	w8, w8, w0, asr #20
100000de0: 11000509    	add	w9, w8, #0x1
100000de4: 530e7d2a    	lsr	w10, w9, #14
100000de8: 35001bca    	cbnz	w10, 0x100001160 <_decodeAndExecute+0xb64>
100000dec: 5288010a    	mov	w10, #0x4008            ; =16392
100000df0: 8b0a02aa    	add	x10, x21, x10
100000df4: 38684948    	ldrb	w8, [x10, w8, uxtw]
100000df8: 38694949    	ldrb	w9, [x10, w9, uxtw]
100000dfc: 53103d08    	lsl	w8, w8, #16
100000e00: 2a096108    	orr	w8, w8, w9, lsl #24
100000e04: 13107d08    	asr	w8, w8, #16
100000e08: 8b334aa9    	add	x9, x21, w19, uxtw #2
100000e0c: 5290010a    	mov	w10, #0x8008            ; =32776
100000e10: b82a6928    	str	w8, [x9, x10]
100000e14: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000e18: 91304400    	add	x0, x0, #0xc11
100000e1c: 140000d3    	b	0x100001168 <_decodeAndExecute+0xb6c>
100000e20: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000e24: 91001108    	add	x8, x8, #0x4
100000e28: 52900109    	mov	w9, #0x8008             ; =32776
100000e2c: 8b090109    	add	x9, x8, x9
100000e30: 71000adf    	cmp	w22, #0x2
100000e34: 54002601    	b.ne	0x1000012f4 <_decodeAndExecute+0xcf8>
100000e38: b874592a    	ldr	w10, [x9, w20, uxtw #2]
100000e3c: 6b15015f    	cmp	w10, w21
100000e40: 1a9fa7ea    	cset	w10, lt
100000e44: b833592a    	str	w10, [x9, w19, uxtw #2]
100000e48: b9400109    	ldr	w9, [x8]
100000e4c: 11001129    	add	w9, w9, #0x4
100000e50: b9000109    	str	w9, [x8]
100000e54: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000e58: 9130e400    	add	x0, x0, #0xc39
100000e5c: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000e60: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000e64: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000e68: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000e6c: 910143ff    	add	sp, sp, #0x50
100000e70: 140002d3    	b	0x1000019bc <_scanf+0x1000019bc>
100000e74: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000e78: 91001108    	add	x8, x8, #0x4
100000e7c: 52900109    	mov	w9, #0x8008             ; =32776
100000e80: 8b090109    	add	x9, x8, x9
100000e84: 71001adf    	cmp	w22, #0x6
100000e88: 54002541    	b.ne	0x100001330 <_decodeAndExecute+0xd34>
100000e8c: b874592a    	ldr	w10, [x9, w20, uxtw #2]
100000e90: 2a15014a    	orr	w10, w10, w21
100000e94: b833592a    	str	w10, [x9, w19, uxtw #2]
100000e98: b9400109    	ldr	w9, [x8]
100000e9c: 11001129    	add	w9, w9, #0x4
100000ea0: b9000109    	str	w9, [x8]
100000ea4: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000ea8: 91314c00    	add	x0, x0, #0xc53
100000eac: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000eb0: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000eb4: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000eb8: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000ebc: 910143ff    	add	sp, sp, #0x50
100000ec0: 140002bf    	b	0x1000019bc <_scanf+0x1000019bc>
100000ec4: 90000056    	adrp	x22, 0x100008000 <_show_instruction>
100000ec8: 910012d6    	add	x22, x22, #0x4
100000ecc: 8b354ac8    	add	x8, x22, w21, uxtw #2
100000ed0: 52900109    	mov	w9, #0x8008             ; =32776
100000ed4: b8696908    	ldr	w8, [x8, x9]
100000ed8: 0b140109    	add	w9, w8, w20
100000edc: 11000528    	add	w8, w9, #0x1
100000ee0: 530e7d0a    	lsr	w10, w8, #14
100000ee4: 350007ea    	cbnz	w10, 0x100000fe0 <_decodeAndExecute+0x9e4>
100000ee8: 8b334aca    	add	x10, x22, w19, uxtw #2
100000eec: 5290010b    	mov	w11, #0x8008            ; =32776
100000ef0: b86b694c    	ldr	w12, [x10, x11]
100000ef4: 5288010d    	mov	w13, #0x4008            ; =16392
100000ef8: 8b0d02cd    	add	x13, x22, x13
100000efc: 382949ac    	strb	w12, [x13, w9, uxtw]
100000f00: b86b6949    	ldr	w9, [x10, x11]
100000f04: 53087d29    	lsr	w9, w9, #8
100000f08: 382849a9    	strb	w9, [x13, w8, uxtw]
100000f0c: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000f10: 912f2400    	add	x0, x0, #0xbc9
100000f14: 14000035    	b	0x100000fe8 <_decodeAndExecute+0x9ec>
100000f18: 90000048    	adrp	x8, 0x100008000 <_show_instruction>
100000f1c: 91001108    	add	x8, x8, #0x4
100000f20: 52900109    	mov	w9, #0x8008             ; =32776
100000f24: 8b090109    	add	x9, x8, x9
100000f28: 71000aff    	cmp	w23, #0x2
100000f2c: 540026c1    	b.ne	0x100001404 <_decodeAndExecute+0xe08>
100000f30: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100000f34: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100000f38: 6b0b015f    	cmp	w10, w11
100000f3c: 1a9fa7ea    	cset	w10, lt
100000f40: b833592a    	str	w10, [x9, w19, uxtw #2]
100000f44: b9400109    	ldr	w9, [x8]
100000f48: 11001129    	add	w9, w9, #0x4
100000f4c: b9000109    	str	w9, [x8]
100000f50: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000f54: 91318400    	add	x0, x0, #0xc61
100000f58: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000f5c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100000f60: a94257f6    	ldp	x22, x21, [sp, #0x20]
100000f64: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100000f68: 910143ff    	add	sp, sp, #0x50
100000f6c: 14000294    	b	0x1000019bc <_scanf+0x1000019bc>
100000f70: 90000056    	adrp	x22, 0x100008000 <_show_instruction>
100000f74: 910012d6    	add	x22, x22, #0x4
100000f78: 8b354ac8    	add	x8, x22, w21, uxtw #2
100000f7c: 52900109    	mov	w9, #0x8008             ; =32776
100000f80: b8696908    	ldr	w8, [x8, x9]
100000f84: 0b140109    	add	w9, w8, w20
100000f88: 11000d28    	add	w8, w9, #0x3
100000f8c: 530e7d0a    	lsr	w10, w8, #14
100000f90: 3500028a    	cbnz	w10, 0x100000fe0 <_decodeAndExecute+0x9e4>
100000f94: 8b334aca    	add	x10, x22, w19, uxtw #2
100000f98: 5290010b    	mov	w11, #0x8008            ; =32776
100000f9c: 8b0b014a    	add	x10, x10, x11
100000fa0: b940014b    	ldr	w11, [x10]
100000fa4: 5288010c    	mov	w12, #0x4008            ; =16392
100000fa8: 8b0c02cc    	add	x12, x22, x12
100000fac: 3829498b    	strb	w11, [x12, w9, uxtw]
100000fb0: b940014b    	ldr	w11, [x10]
100000fb4: 53087d6b    	lsr	w11, w11, #8
100000fb8: 1100052d    	add	w13, w9, #0x1
100000fbc: 382d498b    	strb	w11, [x12, w13, uxtw]
100000fc0: 7940054b    	ldrh	w11, [x10, #0x2]
100000fc4: 11000929    	add	w9, w9, #0x2
100000fc8: 3829498b    	strb	w11, [x12, w9, uxtw]
100000fcc: 39400d49    	ldrb	w9, [x10, #0x3]
100000fd0: 38284989    	strb	w9, [x12, w8, uxtw]
100000fd4: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000fd8: 912f1800    	add	x0, x0, #0xbc6
100000fdc: 14000003    	b	0x100000fe8 <_decodeAndExecute+0x9ec>
100000fe0: b0000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100000fe4: 912f3000    	add	x0, x0, #0xbcc
100000fe8: 94000275    	bl	0x1000019bc <_scanf+0x1000019bc>
100000fec: b94002c8    	ldr	w8, [x22]
100000ff0: 11001108    	add	w8, w8, #0x4
100000ff4: b90002c8    	str	w8, [x22]
100000ff8: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100000ffc: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001000: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001004: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001008: 910143ff    	add	sp, sp, #0x50
10000100c: d65f03c0    	ret
100001010: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
100001014: 91001108    	add	x8, x8, #0x4
100001018: 52900109    	mov	w9, #0x8008             ; =32776
10000101c: 8b090109    	add	x9, x8, x9
100001020: 71001aff    	cmp	w23, #0x6
100001024: 54002101    	b.ne	0x100001444 <_decodeAndExecute+0xe48>
100001028: b875592a    	ldr	w10, [x9, w21, uxtw #2]
10000102c: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100001030: 2a0a016a    	orr	w10, w11, w10
100001034: b833592a    	str	w10, [x9, w19, uxtw #2]
100001038: b9400109    	ldr	w9, [x8]
10000103c: 11001129    	add	w9, w9, #0x4
100001040: b9000109    	str	w9, [x8]
100001044: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001048: 9131c400    	add	x0, x0, #0xc71
10000104c: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001050: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001054: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001058: a9415ff8    	ldp	x24, x23, [sp, #0x10]
10000105c: 910143ff    	add	sp, sp, #0x50
100001060: 14000257    	b	0x1000019bc <_scanf+0x1000019bc>
100001064: f0000035    	adrp	x21, 0x100008000 <_show_instruction>
100001068: 910012b5    	add	x21, x21, #0x4
10000106c: 8b344aa8    	add	x8, x21, w20, uxtw #2
100001070: 52900109    	mov	w9, #0x8008             ; =32776
100001074: b8696908    	ldr	w8, [x8, x9]
100001078: 0b805108    	add	w8, w8, w0, asr #20
10000107c: 11000909    	add	w9, w8, #0x2
100001080: 530e7d2a    	lsr	w10, w9, #14
100001084: 3500046a    	cbnz	w10, 0x100001110 <_decodeAndExecute+0xb14>
100001088: 5288010a    	mov	w10, #0x4008            ; =16392
10000108c: 8b0a02aa    	add	x10, x21, x10
100001090: 3868494b    	ldrb	w11, [x10, w8, uxtw]
100001094: 1100050c    	add	w12, w8, #0x1
100001098: 386c494c    	ldrb	w12, [x10, w12, uxtw]
10000109c: 38694949    	ldrb	w9, [x10, w9, uxtw]
1000010a0: 2a0c216b    	orr	w11, w11, w12, lsl #8
1000010a4: 2a094169    	orr	w9, w11, w9, lsl #16
1000010a8: 11000d08    	add	w8, w8, #0x3
1000010ac: 38684948    	ldrb	w8, [x10, w8, uxtw]
1000010b0: 2a086128    	orr	w8, w9, w8, lsl #24
1000010b4: 8b334aa9    	add	x9, x21, w19, uxtw #2
1000010b8: 5290010a    	mov	w10, #0x8008            ; =32776
1000010bc: b82a6928    	str	w8, [x9, x10]
1000010c0: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000010c4: 91303800    	add	x0, x0, #0xc0e
1000010c8: 14000028    	b	0x100001168 <_decodeAndExecute+0xb6c>
1000010cc: f0000035    	adrp	x21, 0x100008000 <_show_instruction>
1000010d0: 910012b5    	add	x21, x21, #0x4
1000010d4: 8b344aa8    	add	x8, x21, w20, uxtw #2
1000010d8: 52900109    	mov	w9, #0x8008             ; =32776
1000010dc: b8696908    	ldr	w8, [x8, x9]
1000010e0: 0b805108    	add	w8, w8, w0, asr #20
1000010e4: 530e7d09    	lsr	w9, w8, #14
1000010e8: 35000149    	cbnz	w9, 0x100001110 <_decodeAndExecute+0xb14>
1000010ec: 8b2842a8    	add	x8, x21, w8, uxtw
1000010f0: 52880109    	mov	w9, #0x4008             ; =16392
1000010f4: 38696908    	ldrb	w8, [x8, x9]
1000010f8: 8b334aa9    	add	x9, x21, w19, uxtw #2
1000010fc: 5290010a    	mov	w10, #0x8008            ; =32776
100001100: b82a6928    	str	w8, [x9, x10]
100001104: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001108: 912fbc00    	add	x0, x0, #0xbef
10000110c: 14000017    	b	0x100001168 <_decodeAndExecute+0xb6c>
100001110: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001114: 912fcc00    	add	x0, x0, #0xbf3
100001118: 14000014    	b	0x100001168 <_decodeAndExecute+0xb6c>
10000111c: f0000035    	adrp	x21, 0x100008000 <_show_instruction>
100001120: 910012b5    	add	x21, x21, #0x4
100001124: 8b344aa8    	add	x8, x21, w20, uxtw #2
100001128: 52900109    	mov	w9, #0x8008             ; =32776
10000112c: b8696908    	ldr	w8, [x8, x9]
100001130: 0b805108    	add	w8, w8, w0, asr #20
100001134: 530e7d09    	lsr	w9, w8, #14
100001138: 35000149    	cbnz	w9, 0x100001160 <_decodeAndExecute+0xb64>
10000113c: 8b2842a8    	add	x8, x21, w8, uxtw
100001140: 52880109    	mov	w9, #0x4008             ; =16392
100001144: 38e96908    	ldrsb	w8, [x8, x9]
100001148: 8b334aa9    	add	x9, x21, w19, uxtw #2
10000114c: 5290010a    	mov	w10, #0x8008            ; =32776
100001150: b82a6928    	str	w8, [x9, x10]
100001154: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001158: 9130c000    	add	x0, x0, #0xc30
10000115c: 14000003    	b	0x100001168 <_decodeAndExecute+0xb6c>
100001160: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001164: 91305000    	add	x0, x0, #0xc14
100001168: 94000215    	bl	0x1000019bc <_scanf+0x1000019bc>
10000116c: b94002a8    	ldr	w8, [x21]
100001170: 11001108    	add	w8, w8, #0x4
100001174: b90002a8    	str	w8, [x21]
100001178: a9447bfd    	ldp	x29, x30, [sp, #0x40]
10000117c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001180: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001184: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001188: 910143ff    	add	sp, sp, #0x50
10000118c: d65f03c0    	ret
100001190: f0000036    	adrp	x22, 0x100008000 <_show_instruction>
100001194: 910012d6    	add	x22, x22, #0x4
100001198: 52900108    	mov	w8, #0x8008             ; =32776
10000119c: 8b0802c8    	add	x8, x22, x8
1000011a0: b8755909    	ldr	w9, [x8, w21, uxtw #2]
1000011a4: b8745908    	ldr	w8, [x8, w20, uxtw #2]
1000011a8: 6b08013f    	cmp	w9, w8
1000011ac: 540016a1    	b.ne	0x100001480 <_decodeAndExecute+0xe84>
1000011b0: b94002c8    	ldr	w8, [x22]
1000011b4: 0b130108    	add	w8, w8, w19
1000011b8: 140000b7    	b	0x100001494 <_decodeAndExecute+0xe98>
1000011bc: f0000036    	adrp	x22, 0x100008000 <_show_instruction>
1000011c0: 910012d6    	add	x22, x22, #0x4
1000011c4: 52900108    	mov	w8, #0x8008             ; =32776
1000011c8: 8b0802c8    	add	x8, x22, x8
1000011cc: b8755909    	ldr	w9, [x8, w21, uxtw #2]
1000011d0: b8745908    	ldr	w8, [x8, w20, uxtw #2]
1000011d4: 6b08013f    	cmp	w9, w8
1000011d8: 5400170a    	b.ge	0x1000014b8 <_decodeAndExecute+0xebc>
1000011dc: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000011e0: 912e8c00    	add	x0, x0, #0xba3
1000011e4: 940001f6    	bl	0x1000019bc <_scanf+0x1000019bc>
1000011e8: b94002c8    	ldr	w8, [x22]
1000011ec: 11001108    	add	w8, w8, #0x4
1000011f0: 140000b4    	b	0x1000014c0 <_decodeAndExecute+0xec4>
1000011f4: f0000036    	adrp	x22, 0x100008000 <_show_instruction>
1000011f8: 910012d6    	add	x22, x22, #0x4
1000011fc: 52900108    	mov	w8, #0x8008             ; =32776
100001200: 8b0802c8    	add	x8, x22, x8
100001204: b8755909    	ldr	w9, [x8, w21, uxtw #2]
100001208: b8745908    	ldr	w8, [x8, w20, uxtw #2]
10000120c: 6b08013f    	cmp	w9, w8
100001210: 540019c1    	b.ne	0x100001548 <_decodeAndExecute+0xf4c>
100001214: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001218: 912e8c00    	add	x0, x0, #0xba3
10000121c: 940001e8    	bl	0x1000019bc <_scanf+0x1000019bc>
100001220: b94002c8    	ldr	w8, [x22]
100001224: 11001108    	add	w8, w8, #0x4
100001228: 140000ca    	b	0x100001550 <_decodeAndExecute+0xf54>
10000122c: f0000036    	adrp	x22, 0x100008000 <_show_instruction>
100001230: 910012d6    	add	x22, x22, #0x4
100001234: 52900108    	mov	w8, #0x8008             ; =32776
100001238: 8b0802c8    	add	x8, x22, x8
10000123c: b8755909    	ldr	w9, [x8, w21, uxtw #2]
100001240: b8745908    	ldr	w8, [x8, w20, uxtw #2]
100001244: 6b08013f    	cmp	w9, w8
100001248: 54001962    	b.hs	0x100001574 <_decodeAndExecute+0xf78>
10000124c: b94002c8    	ldr	w8, [x22]
100001250: 0b130108    	add	w8, w8, w19
100001254: 140000cd    	b	0x100001588 <_decodeAndExecute+0xf8c>
100001258: 53147c08    	lsr	w8, w0, #20
10000125c: f0000029    	adrp	x9, 0x100008000 <_show_instruction>
100001260: 91001129    	add	x9, x9, #0x4
100001264: 5290010a    	mov	w10, #0x8008            ; =32776
100001268: 8b0a012a    	add	x10, x9, x10
10000126c: b874594b    	ldr	w11, [x10, w20, uxtw #2]
100001270: 1ac82168    	lsl	w8, w11, w8
100001274: b8335948    	str	w8, [x10, w19, uxtw #2]
100001278: b9400128    	ldr	w8, [x9]
10000127c: 11001108    	add	w8, w8, #0x4
100001280: b9000128    	str	w8, [x9]
100001284: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001288: 91313800    	add	x0, x0, #0xc4e
10000128c: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001290: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001294: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001298: a9415ff8    	ldp	x24, x23, [sp, #0x10]
10000129c: 910143ff    	add	sp, sp, #0x50
1000012a0: 140001c7    	b	0x1000019bc <_scanf+0x1000019bc>
1000012a4: 53197c08    	lsr	w8, w0, #25
1000012a8: 35001828    	cbnz	w8, 0x1000015ac <_decodeAndExecute+0xfb0>
1000012ac: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
1000012b0: 91001108    	add	x8, x8, #0x4
1000012b4: 52900109    	mov	w9, #0x8008             ; =32776
1000012b8: 8b090109    	add	x9, x8, x9
1000012bc: b874592a    	ldr	w10, [x9, w20, uxtw #2]
1000012c0: 1ad5254a    	lsr	w10, w10, w21
1000012c4: b833592a    	str	w10, [x9, w19, uxtw #2]
1000012c8: b9400109    	ldr	w9, [x8]
1000012cc: 11001129    	add	w9, w9, #0x4
1000012d0: b9000109    	str	w9, [x8]
1000012d4: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000012d8: 91312400    	add	x0, x0, #0xc49
1000012dc: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000012e0: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000012e4: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000012e8: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000012ec: 910143ff    	add	sp, sp, #0x50
1000012f0: 140001b3    	b	0x1000019bc <_scanf+0x1000019bc>
1000012f4: b874592a    	ldr	w10, [x9, w20, uxtw #2]
1000012f8: 6b15015f    	cmp	w10, w21
1000012fc: 1a9f27ea    	cset	w10, lo
100001300: b833592a    	str	w10, [x9, w19, uxtw #2]
100001304: b9400109    	ldr	w9, [x8]
100001308: 11001129    	add	w9, w9, #0x4
10000130c: b9000109    	str	w9, [x8]
100001310: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001314: 9130cc00    	add	x0, x0, #0xc33
100001318: a9447bfd    	ldp	x29, x30, [sp, #0x40]
10000131c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001320: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001324: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001328: 910143ff    	add	sp, sp, #0x50
10000132c: 140001a4    	b	0x1000019bc <_scanf+0x1000019bc>
100001330: b874592a    	ldr	w10, [x9, w20, uxtw #2]
100001334: 0a15014a    	and	w10, w10, w21
100001338: b833592a    	str	w10, [x9, w19, uxtw #2]
10000133c: b9400109    	ldr	w9, [x8]
100001340: 11001129    	add	w9, w9, #0x4
100001344: b9000109    	str	w9, [x8]
100001348: a9447bfd    	ldp	x29, x30, [sp, #0x40]
10000134c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001350: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001354: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001358: 910143ff    	add	sp, sp, #0x50
10000135c: d65f03c0    	ret
100001360: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
100001364: 91001108    	add	x8, x8, #0x4
100001368: 52900109    	mov	w9, #0x8008             ; =32776
10000136c: 8b090109    	add	x9, x8, x9
100001370: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100001374: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100001378: 1acb214a    	lsl	w10, w10, w11
10000137c: b833592a    	str	w10, [x9, w19, uxtw #2]
100001380: b9400109    	ldr	w9, [x8]
100001384: 11001129    	add	w9, w9, #0x4
100001388: b9000109    	str	w9, [x8]
10000138c: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001390: 9131e000    	add	x0, x0, #0xc78
100001394: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001398: a9434ff4    	ldp	x20, x19, [sp, #0x30]
10000139c: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000013a0: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000013a4: 910143ff    	add	sp, sp, #0x50
1000013a8: 14000185    	b	0x1000019bc <_scanf+0x1000019bc>
1000013ac: 710082df    	cmp	w22, #0x20
1000013b0: 540014e0    	b.eq	0x10000164c <_decodeAndExecute+0x1050>
1000013b4: 35fffcb6    	cbnz	w22, 0x100001348 <_decodeAndExecute+0xd4c>
1000013b8: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
1000013bc: 91001108    	add	x8, x8, #0x4
1000013c0: 52900109    	mov	w9, #0x8008             ; =32776
1000013c4: 8b090109    	add	x9, x8, x9
1000013c8: b875592a    	ldr	w10, [x9, w21, uxtw #2]
1000013cc: b874592b    	ldr	w11, [x9, w20, uxtw #2]
1000013d0: 1acb254a    	lsr	w10, w10, w11
1000013d4: b833592a    	str	w10, [x9, w19, uxtw #2]
1000013d8: b9400109    	ldr	w9, [x8]
1000013dc: 11001129    	add	w9, w9, #0x4
1000013e0: b9000109    	str	w9, [x8]
1000013e4: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000013e8: 9131a400    	add	x0, x0, #0xc69
1000013ec: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000013f0: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000013f4: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000013f8: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000013fc: 910143ff    	add	sp, sp, #0x50
100001400: 1400016f    	b	0x1000019bc <_scanf+0x1000019bc>
100001404: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100001408: b874592b    	ldr	w11, [x9, w20, uxtw #2]
10000140c: 6b0b015f    	cmp	w10, w11
100001410: 1a9f27ea    	cset	w10, lo
100001414: b833592a    	str	w10, [x9, w19, uxtw #2]
100001418: b9400109    	ldr	w9, [x8]
10000141c: 11001129    	add	w9, w9, #0x4
100001420: b9000109    	str	w9, [x8]
100001424: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001428: 91317000    	add	x0, x0, #0xc5c
10000142c: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001430: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001434: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001438: a9415ff8    	ldp	x24, x23, [sp, #0x10]
10000143c: 910143ff    	add	sp, sp, #0x50
100001440: 1400015f    	b	0x1000019bc <_scanf+0x1000019bc>
100001444: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100001448: b874592b    	ldr	w11, [x9, w20, uxtw #2]
10000144c: 0a0a016a    	and	w10, w11, w10
100001450: b833592a    	str	w10, [x9, w19, uxtw #2]
100001454: b9400109    	ldr	w9, [x8]
100001458: 11001129    	add	w9, w9, #0x4
10000145c: b9000109    	str	w9, [x8]
100001460: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001464: 9131b400    	add	x0, x0, #0xc6d
100001468: a9447bfd    	ldp	x29, x30, [sp, #0x40]
10000146c: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001470: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001474: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001478: 910143ff    	add	sp, sp, #0x50
10000147c: 14000150    	b	0x1000019bc <_scanf+0x1000019bc>
100001480: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001484: 912e8c00    	add	x0, x0, #0xba3
100001488: 9400014d    	bl	0x1000019bc <_scanf+0x1000019bc>
10000148c: b94002c8    	ldr	w8, [x22]
100001490: 11001108    	add	w8, w8, #0x4
100001494: b90002c8    	str	w8, [x22]
100001498: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000149c: 912f0800    	add	x0, x0, #0xbc2
1000014a0: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000014a4: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000014a8: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000014ac: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000014b0: 910143ff    	add	sp, sp, #0x50
1000014b4: 14000142    	b	0x1000019bc <_scanf+0x1000019bc>
1000014b8: b94002c8    	ldr	w8, [x22]
1000014bc: 0b130108    	add	w8, w8, w19
1000014c0: b90002c8    	str	w8, [x22]
1000014c4: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000014c8: 912e5c00    	add	x0, x0, #0xb97
1000014cc: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000014d0: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000014d4: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000014d8: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000014dc: 910143ff    	add	sp, sp, #0x50
1000014e0: 14000137    	b	0x1000019bc <_scanf+0x1000019bc>
1000014e4: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000014e8: 912e8c00    	add	x0, x0, #0xba3
1000014ec: 94000134    	bl	0x1000019bc <_scanf+0x1000019bc>
1000014f0: b94002c8    	ldr	w8, [x22]
1000014f4: 11001108    	add	w8, w8, #0x4
1000014f8: b90002c8    	str	w8, [x22]
1000014fc: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001500: 912e6c00    	add	x0, x0, #0xb9b
100001504: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001508: a9434ff4    	ldp	x20, x19, [sp, #0x30]
10000150c: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001510: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001514: 910143ff    	add	sp, sp, #0x50
100001518: 14000129    	b	0x1000019bc <_scanf+0x1000019bc>
10000151c: b94002c8    	ldr	w8, [x22]
100001520: 0b130108    	add	w8, w8, w19
100001524: b90002c8    	str	w8, [x22]
100001528: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000152c: 912e3400    	add	x0, x0, #0xb8d
100001530: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001534: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001538: a94257f6    	ldp	x22, x21, [sp, #0x20]
10000153c: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001540: 910143ff    	add	sp, sp, #0x50
100001544: 1400011e    	b	0x1000019bc <_scanf+0x1000019bc>
100001548: b94002c8    	ldr	w8, [x22]
10000154c: 0b130108    	add	w8, w8, w19
100001550: b90002c8    	str	w8, [x22]
100001554: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001558: 912e7c00    	add	x0, x0, #0xb9f
10000155c: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001560: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001564: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001568: a9415ff8    	ldp	x24, x23, [sp, #0x10]
10000156c: 910143ff    	add	sp, sp, #0x50
100001570: 14000113    	b	0x1000019bc <_scanf+0x1000019bc>
100001574: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001578: 912e8c00    	add	x0, x0, #0xba3
10000157c: 94000110    	bl	0x1000019bc <_scanf+0x1000019bc>
100001580: b94002c8    	ldr	w8, [x22]
100001584: 11001108    	add	w8, w8, #0x4
100001588: b90002c8    	str	w8, [x22]
10000158c: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001590: 912e4800    	add	x0, x0, #0xb92
100001594: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001598: a9434ff4    	ldp	x20, x19, [sp, #0x30]
10000159c: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000015a0: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000015a4: 910143ff    	add	sp, sp, #0x50
1000015a8: 14000105    	b	0x1000019bc <_scanf+0x1000019bc>
1000015ac: 710082ff    	cmp	w23, #0x20
1000015b0: 54000741    	b.ne	0x100001698 <_decodeAndExecute+0x109c>
1000015b4: 53147c08    	lsr	w8, w0, #20
1000015b8: f0000029    	adrp	x9, 0x100008000 <_show_instruction>
1000015bc: 91001129    	add	x9, x9, #0x4
1000015c0: 5290010a    	mov	w10, #0x8008            ; =32776
1000015c4: 8b0a012a    	add	x10, x9, x10
1000015c8: b874594b    	ldr	w11, [x10, w20, uxtw #2]
1000015cc: 1ac82968    	asr	w8, w11, w8
1000015d0: b8335948    	str	w8, [x10, w19, uxtw #2]
1000015d4: b9400128    	ldr	w8, [x9]
1000015d8: 11001108    	add	w8, w8, #0x4
1000015dc: b9000128    	str	w8, [x9]
1000015e0: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000015e4: 91311000    	add	x0, x0, #0xc44
1000015e8: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000015ec: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000015f0: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000015f4: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000015f8: 910143ff    	add	sp, sp, #0x50
1000015fc: 140000f0    	b	0x1000019bc <_scanf+0x1000019bc>
100001600: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
100001604: 91001108    	add	x8, x8, #0x4
100001608: 52900109    	mov	w9, #0x8008             ; =32776
10000160c: 8b090109    	add	x9, x8, x9
100001610: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100001614: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100001618: 4b0b014a    	sub	w10, w10, w11
10000161c: b833592a    	str	w10, [x9, w19, uxtw #2]
100001620: b9400109    	ldr	w9, [x8]
100001624: 11001129    	add	w9, w9, #0x4
100001628: b9000109    	str	w9, [x8]
10000162c: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001630: 9131f000    	add	x0, x0, #0xc7c
100001634: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001638: a9434ff4    	ldp	x20, x19, [sp, #0x30]
10000163c: a94257f6    	ldp	x22, x21, [sp, #0x20]
100001640: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001644: 910143ff    	add	sp, sp, #0x50
100001648: 140000dd    	b	0x1000019bc <_scanf+0x1000019bc>
10000164c: f0000028    	adrp	x8, 0x100008000 <_show_instruction>
100001650: 91001108    	add	x8, x8, #0x4
100001654: 52900109    	mov	w9, #0x8008             ; =32776
100001658: 8b090109    	add	x9, x8, x9
10000165c: b875592a    	ldr	w10, [x9, w21, uxtw #2]
100001660: b874592b    	ldr	w11, [x9, w20, uxtw #2]
100001664: 1acb294a    	asr	w10, w10, w11
100001668: b833592a    	str	w10, [x9, w19, uxtw #2]
10000166c: b9400109    	ldr	w9, [x8]
100001670: 11001129    	add	w9, w9, #0x4
100001674: b9000109    	str	w9, [x8]
100001678: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000167c: 91319400    	add	x0, x0, #0xc65
100001680: a9447bfd    	ldp	x29, x30, [sp, #0x40]
100001684: a9434ff4    	ldp	x20, x19, [sp, #0x30]
100001688: a94257f6    	ldp	x22, x21, [sp, #0x20]
10000168c: a9415ff8    	ldp	x24, x23, [sp, #0x10]
100001690: 910143ff    	add	sp, sp, #0x50
100001694: 140000ca    	b	0x1000019bc <_scanf+0x1000019bc>
100001698: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000169c: 9130f800    	add	x0, x0, #0xc3e
1000016a0: a9447bfd    	ldp	x29, x30, [sp, #0x40]
1000016a4: a9434ff4    	ldp	x20, x19, [sp, #0x30]
1000016a8: a94257f6    	ldp	x22, x21, [sp, #0x20]
1000016ac: a9415ff8    	ldp	x24, x23, [sp, #0x10]
1000016b0: 910143ff    	add	sp, sp, #0x50
1000016b4: 140000c2    	b	0x1000019bc <_scanf+0x1000019bc>

00000001000016b8 <_show_registers>:
1000016b8: d10183ff    	sub	sp, sp, #0x60
1000016bc: a90167fa    	stp	x26, x25, [sp, #0x10]
1000016c0: a9025ff8    	stp	x24, x23, [sp, #0x20]
1000016c4: a90357f6    	stp	x22, x21, [sp, #0x30]
1000016c8: a9044ff4    	stp	x20, x19, [sp, #0x40]
1000016cc: a9057bfd    	stp	x29, x30, [sp, #0x50]
1000016d0: 910143fd    	add	x29, sp, #0x50
1000016d4: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000016d8: 91321000    	add	x0, x0, #0xc84
1000016dc: 940000b8    	bl	0x1000019bc <_scanf+0x1000019bc>
1000016e0: d2800016    	mov	x22, #0x0               ; =0
1000016e4: 90000013    	adrp	x19, 0x100001000 <_decodeAndExecute+0xa04>
1000016e8: 912c4a73    	add	x19, x19, #0xb12
1000016ec: f0000017    	adrp	x23, 0x100004000 <_scanf+0x100004000>
1000016f0: 9100a2f7    	add	x23, x23, #0x28
1000016f4: 90000014    	adrp	x20, 0x100001000 <_decodeAndExecute+0xa04>
1000016f8: 912c7e94    	add	x20, x20, #0xb1f
1000016fc: f0000038    	adrp	x24, 0x100008000 <_show_instruction>
100001700: 91001318    	add	x24, x24, #0x4
100001704: 52900119    	mov	w25, #0x8008            ; =32776
100001708: 90000015    	adrp	x21, 0x100001000 <_decodeAndExecute+0xa04>
10000170c: 912c9ab5    	add	x21, x21, #0xb26
100001710: f90003f6    	str	x22, [sp]
100001714: aa1303e0    	mov	x0, x19
100001718: 940000a3    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000171c: f8767ae8    	ldr	x8, [x23, x22, lsl #3]
100001720: f90003e8    	str	x8, [sp]
100001724: aa1403e0    	mov	x0, x20
100001728: 9400009f    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000172c: 8b160b08    	add	x8, x24, x22, lsl #2
100001730: b8796908    	ldr	w8, [x8, x25]
100001734: f90003e8    	str	x8, [sp]
100001738: aa1503e0    	mov	x0, x21
10000173c: 9400009a    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001740: 52800140    	mov	w0, #0xa                ; =10
100001744: 9400009b    	bl	0x1000019b0 <_scanf+0x1000019b0>
100001748: 910006d6    	add	x22, x22, #0x1
10000174c: f10082df    	cmp	x22, #0x20
100001750: 54fffe01    	b.ne	0x100001710 <_show_registers+0x58>
100001754: b9400308    	ldr	w8, [x24]
100001758: f90003e8    	str	x8, [sp]
10000175c: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001760: 912cb800    	add	x0, x0, #0xb2e
100001764: 94000090    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001768: a9457bfd    	ldp	x29, x30, [sp, #0x50]
10000176c: a9444ff4    	ldp	x20, x19, [sp, #0x40]
100001770: a94357f6    	ldp	x22, x21, [sp, #0x30]
100001774: a9425ff8    	ldp	x24, x23, [sp, #0x20]
100001778: a94167fa    	ldp	x26, x25, [sp, #0x10]
10000177c: 910183ff    	add	sp, sp, #0x60
100001780: d65f03c0    	ret

0000000100001784 <_main>:
100001784: d101c3ff    	sub	sp, sp, #0x70
100001788: a9016ffc    	stp	x28, x27, [sp, #0x10]
10000178c: a90267fa    	stp	x26, x25, [sp, #0x20]
100001790: a9035ff8    	stp	x24, x23, [sp, #0x30]
100001794: a90457f6    	stp	x22, x21, [sp, #0x40]
100001798: a9054ff4    	stp	x20, x19, [sp, #0x50]
10000179c: a9067bfd    	stp	x29, x30, [sp, #0x60]
1000017a0: 910183fd    	add	x29, sp, #0x60
1000017a4: f000003a    	adrp	x26, 0x100008000 <_show_instruction>
1000017a8: 9100135a    	add	x26, x26, #0x4
1000017ac: 5290011c    	mov	w28, #0x8008            ; =32776
1000017b0: 8b1c0348    	add	x8, x26, x28
1000017b4: 6f00e400    	movi.2d	v0, #0000000000000000
1000017b8: ad030100    	stp	q0, q0, [x8, #0x60]
1000017bc: ad020100    	stp	q0, q0, [x8, #0x40]
1000017c0: ad010100    	stp	q0, q0, [x8, #0x20]
1000017c4: ad000100    	stp	q0, q0, [x8]
1000017c8: f900035f    	str	xzr, [x26]
1000017cc: 90000008    	adrp	x8, 0x100001000 <_decodeAndExecute+0xa04>
1000017d0: 91328d08    	add	x8, x8, #0xca3
1000017d4: 3dc00100    	ldr	q0, [x8]
1000017d8: 3c808340    	stur	q0, [x26, #0x8]
1000017dc: 3cc0c100    	ldur	q0, [x8, #0xc]
1000017e0: 3c814340    	stur	q0, [x26, #0x14]
1000017e4: 91009340    	add	x0, x26, #0x24
1000017e8: 5287fc81    	mov	w1, #0x3fe4             ; =16356
1000017ec: 9400006b    	bl	0x100001998 <_scanf+0x100001998>
1000017f0: b9000fff    	str	wzr, [sp, #0xc]
1000017f4: 90000014    	adrp	x20, 0x100001000 <_decodeAndExecute+0xa04>
1000017f8: 912d5a94    	add	x20, x20, #0xb56
1000017fc: 90000016    	adrp	x22, 0x100001000 <_decodeAndExecute+0xa04>
100001800: 912c4ad6    	add	x22, x22, #0xb12
100001804: f000001b    	adrp	x27, 0x100004000 <_scanf+0x100004000>
100001808: 9100a37b    	add	x27, x27, #0x28
10000180c: 90000017    	adrp	x23, 0x100001000 <_decodeAndExecute+0xa04>
100001810: 912c7ef7    	add	x23, x23, #0xb1f
100001814: 90000018    	adrp	x24, 0x100001000 <_decodeAndExecute+0xa04>
100001818: 912c9b18    	add	x24, x24, #0xb26
10000181c: 90000019    	adrp	x25, 0x100001000 <_decodeAndExecute+0xa04>
100001820: 912cbb39    	add	x25, x25, #0xb2e
100001824: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
100001828: 912ce000    	add	x0, x0, #0xb38
10000182c: 9400005e    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001830: 910033e8    	add	x8, sp, #0xc
100001834: f90003e8    	str	x8, [sp]
100001838: aa1403e0    	mov	x0, x20
10000183c: 94000063    	bl	0x1000019c8 <_scanf+0x1000019c8>
100001840: b9400fe8    	ldr	w8, [sp, #0xc]
100001844: 34000568    	cbz	w8, 0x1000018f0 <_main+0x16c>
100001848: 7100051f    	cmp	w8, #0x1
10000184c: 540001cb    	b.lt	0x100001884 <_main+0x100>
100001850: 52800015    	mov	w21, #0x0               ; =0
100001854: b83c6b5f    	str	wzr, [x26, x28]
100001858: b9800348    	ldrsw	x8, [x26]
10000185c: 8b080348    	add	x8, x26, x8
100001860: b9400900    	ldr	w0, [x8, #0x8]
100001864: 7100001f    	cmp	w0, #0x0
100001868: 1a9f17f3    	cset	w19, eq
10000186c: 340000e0    	cbz	w0, 0x100001888 <_main+0x104>
100001870: 97fffb63    	bl	0x1000005fc <_decodeAndExecute>
100001874: 110006b5    	add	w21, w21, #0x1
100001878: b9400fe8    	ldr	w8, [sp, #0xc]
10000187c: 6b0802bf    	cmp	w21, w8
100001880: 54fffeab    	b.lt	0x100001854 <_main+0xd0>
100001884: 52800013    	mov	w19, #0x0               ; =0
100001888: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000188c: 91321000    	add	x0, x0, #0xc84
100001890: 9400004b    	bl	0x1000019bc <_scanf+0x1000019bc>
100001894: d2800015    	mov	x21, #0x0               ; =0
100001898: f90003f5    	str	x21, [sp]
10000189c: aa1603e0    	mov	x0, x22
1000018a0: 94000041    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000018a4: f8757b68    	ldr	x8, [x27, x21, lsl #3]
1000018a8: f90003e8    	str	x8, [sp]
1000018ac: aa1703e0    	mov	x0, x23
1000018b0: 9400003d    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000018b4: 8b150b48    	add	x8, x26, x21, lsl #2
1000018b8: b87c6908    	ldr	w8, [x8, x28]
1000018bc: f90003e8    	str	x8, [sp]
1000018c0: aa1803e0    	mov	x0, x24
1000018c4: 94000038    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000018c8: 52800140    	mov	w0, #0xa                ; =10
1000018cc: 94000039    	bl	0x1000019b0 <_scanf+0x1000019b0>
1000018d0: 910006b5    	add	x21, x21, #0x1
1000018d4: f10082bf    	cmp	x21, #0x20
1000018d8: 54fffe01    	b.ne	0x100001898 <_main+0x114>
1000018dc: b9400348    	ldr	w8, [x26]
1000018e0: f90003e8    	str	x8, [sp]
1000018e4: aa1903e0    	mov	x0, x25
1000018e8: 9400002f    	bl	0x1000019a4 <_scanf+0x1000019a4>
1000018ec: 34fff9d3    	cbz	w19, 0x100001824 <_main+0xa0>
1000018f0: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
1000018f4: 91321000    	add	x0, x0, #0xc84
1000018f8: 94000031    	bl	0x1000019bc <_scanf+0x1000019bc>
1000018fc: d2800016    	mov	x22, #0x0               ; =0
100001900: 90000013    	adrp	x19, 0x100001000 <_decodeAndExecute+0xa04>
100001904: 912c4a73    	add	x19, x19, #0xb12
100001908: 90000014    	adrp	x20, 0x100001000 <_decodeAndExecute+0xa04>
10000190c: 912c7e94    	add	x20, x20, #0xb1f
100001910: 52900117    	mov	w23, #0x8008            ; =32776
100001914: 90000015    	adrp	x21, 0x100001000 <_decodeAndExecute+0xa04>
100001918: 912c9ab5    	add	x21, x21, #0xb26
10000191c: f90003f6    	str	x22, [sp]
100001920: aa1303e0    	mov	x0, x19
100001924: 94000020    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001928: f8767b68    	ldr	x8, [x27, x22, lsl #3]
10000192c: f90003e8    	str	x8, [sp]
100001930: aa1403e0    	mov	x0, x20
100001934: 9400001c    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001938: 8b160b48    	add	x8, x26, x22, lsl #2
10000193c: b8776908    	ldr	w8, [x8, x23]
100001940: f90003e8    	str	x8, [sp]
100001944: aa1503e0    	mov	x0, x21
100001948: 94000017    	bl	0x1000019a4 <_scanf+0x1000019a4>
10000194c: 52800140    	mov	w0, #0xa                ; =10
100001950: 94000018    	bl	0x1000019b0 <_scanf+0x1000019b0>
100001954: 910006d6    	add	x22, x22, #0x1
100001958: f10082df    	cmp	x22, #0x20
10000195c: 54fffe01    	b.ne	0x10000191c <_main+0x198>
100001960: b9400348    	ldr	w8, [x26]
100001964: f90003e8    	str	x8, [sp]
100001968: 90000000    	adrp	x0, 0x100001000 <_decodeAndExecute+0xa04>
10000196c: 912cb800    	add	x0, x0, #0xb2e
100001970: 9400000d    	bl	0x1000019a4 <_scanf+0x1000019a4>
100001974: 52800000    	mov	w0, #0x0                ; =0
100001978: a9467bfd    	ldp	x29, x30, [sp, #0x60]
10000197c: a9454ff4    	ldp	x20, x19, [sp, #0x50]
100001980: a94457f6    	ldp	x22, x21, [sp, #0x40]
100001984: a9435ff8    	ldp	x24, x23, [sp, #0x30]
100001988: a94267fa    	ldp	x26, x25, [sp, #0x20]
10000198c: a9416ffc    	ldp	x28, x27, [sp, #0x10]
100001990: 9101c3ff    	add	sp, sp, #0x70
100001994: d65f03c0    	ret

Disassembly of section __TEXT,__stubs:

0000000100001998 <__stubs>:
100001998: f0000010    	adrp	x16, 0x100004000 <_scanf+0x100004000>
10000199c: f9400210    	ldr	x16, [x16]
1000019a0: d61f0200    	br	x16
1000019a4: f0000010    	adrp	x16, 0x100004000 <_scanf+0x100004000>
1000019a8: f9400610    	ldr	x16, [x16, #0x8]
1000019ac: d61f0200    	br	x16
1000019b0: f0000010    	adrp	x16, 0x100004000 <_scanf+0x100004000>
1000019b4: f9400a10    	ldr	x16, [x16, #0x10]
1000019b8: d61f0200    	br	x16
1000019bc: f0000010    	adrp	x16, 0x100004000 <_scanf+0x100004000>
1000019c0: f9400e10    	ldr	x16, [x16, #0x18]
1000019c4: d61f0200    	br	x16
1000019c8: f0000010    	adrp	x16, 0x100004000 <_scanf+0x100004000>
1000019cc: f9401210    	ldr	x16, [x16, #0x20]
1000019d0: d61f0200    	br	x16