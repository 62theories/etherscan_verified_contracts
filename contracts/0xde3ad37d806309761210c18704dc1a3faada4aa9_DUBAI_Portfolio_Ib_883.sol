pragma solidity 		^0.4.21	;						
									
contract	DUBAI_Portfolio_Ib_883				{				
									
	mapping (address =&gt; uint256) public balanceOf;								
									
	string	public		name =	&quot;	DUBAI_Portfolio_Ib_883		&quot;	;
	string	public		symbol =	&quot;	DUBAI883I		&quot;	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		728002043355369000000000000					;	
									
	event Transfer(address indexed from, address indexed to, uint256 value);								
									
	function SimpleERC20Token() public {								
		balanceOf[msg.sender] = totalSupply;							
		emit Transfer(address(0), msg.sender, totalSupply);							
	}								
									
	function transfer(address to, uint256 value) public returns (bool success) {								
		require(balanceOf[msg.sender] &gt;= value);							
									
		balanceOf[msg.sender] -= value;  // deduct from sender&#39;s balance							
		balanceOf[to] += value;          // add to recipient&#39;s balance							
		emit Transfer(msg.sender, to, value);							
		return true;							
	}								
									
	event Approval(address indexed owner, address indexed spender, uint256 value);								
									
	mapping(address =&gt; mapping(address =&gt; uint256)) public allowance;								
									
	function approve(address spender, uint256 value)								
		public							
		returns (bool success)							
	{								
		allowance[msg.sender][spender] = value;							
		emit Approval(msg.sender, spender, value);							
		return true;							
	}								
									
	function transferFrom(address from, address to, uint256 value)								
		public							
		returns (bool success)							
	{								
		require(value &lt;= balanceOf[from]);							
		require(value &lt;= allowance[from][msg.sender]);							
									
		balanceOf[from] -= value;							
		balanceOf[to] += value;							
		allowance[from][msg.sender] -= value;							
		emit Transfer(from, to, value);							
		return true;							
	}								
//}									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
// Programme d&#39;&#233;mission - Lignes 1 &#224; 10									
//									
//									
//									
//									
//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
//         [ Adresse export&#233;e ]									
//         [ Unit&#233; ; Limite basse ; Limite haute ]									
//         [ Hex ]									
//									
//									
//									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_1_____AJMAN_BANK_20250515 &gt;									
//        &lt; L6ZuGdiGpSqAsRUnN56E6LKKU97imk8mfmeZzx1g3R7gId211fww634GQ0PJS42q &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000000000000.000000000000000000 ; 000000015884741.083761000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000000000183CFA &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_2_____AL_SALAM_BANK_SUDAN_20250515 &gt;									
//        &lt; acBz1cP0SiCn715k2T3ScluavLtO1oiuQ24cGq53p9l40qGoj9Y0WLM06USE5V06 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000015884741.083761000000000000 ; 000000032229705.695558200000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000183CFA312DBB &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_3_____Amlak_Finance_20250515 &gt;									
//        &lt; b13M9olAjl42ZeNb6IUPD0dPvuq3T6YDEu6F22d8kdS5t8JnLAiuRhcVPWQ60IrV &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000032229705.695558200000000000 ; 000000049089220.940360200000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000312DBB4AE77A &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_4_____Commercial_Bank_Dubai_20250515 &gt;									
//        &lt; 9Q96dbdpvCDkEy8Kd3KnkSgzVc5ZCRY64p7y4zwVA91AkGnTY8iQ2fN0kHAhPRUP &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000049089220.940360200000000000 ; 000000068091782.527806200000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000004AE77A67E65A &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_5_____Dubai_Islamic_Bank_20250515 &gt;									
//        &lt; h1w9qAml7o12Z4WO9gFUIT26NHfvE3wm5e9VS9rU8hVnAHQeJ4Uhnr1vPzAutfJv &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000068091782.527806200000000000 ; 000000087470978.004263900000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000000067E65A85785A &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_6_____Emirates_Islamic_Bank_20250515 &gt;									
//        &lt; anZ957Tk1xTUQY68zG3t6E57tTQA2fzxre9Q3gCHh1LV5j2B3446sTt2Rl7pISY4 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000087470978.004263900000000000 ; 000000106997977.181169000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000000085785AA34416 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_7_____Emirates_Investment_Bank_20250515 &gt;									
//        &lt; H8CXH4mU8q2uqT180Gu6yiqs25uas01DszW3e37b20KPOoQND3b6ImLpuI7H2nk7 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000106997977.181169000000000000 ; 000000128630093.592656000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000A34416C44621 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_8_____Emirates_NBD_20250515 &gt;									
//        &lt; S38niN1ZJ8xK4yTUo5q9b13HB7a2x9m72o1td8XdcMnp084G2ws778P352D1qY2O &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000128630093.592656000000000000 ; 000000148482651.177864000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000C44621E29109 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_9_____Gulf_Finance_House_BSC_20250515 &gt;									
//        &lt; ht6vJF1n3YcPxFFU9qzpPc9ieOfB1hGF4c0pPa37R4KfKasVXYemlh7o8MxTx0g1 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000148482651.177864000000000000 ; 000000166024168.285934000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000000E29109FD5531 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_10_____Mashreqbank_20250515 &gt;									
//        &lt; NmEa7LIktdZ3S5HnCtAXX66JM988VYjq37iVxquPT9HG4VXR41TY504M8726c17W &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000166024168.285934000000000000 ; 000000181090929.627096000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000000FD553111452A5 &gt;									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
// Programme d&#39;&#233;mission - Lignes 11 &#224; 20									
//									
//									
//									
//									
//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
//         [ Adresse export&#233;e ]									
//         [ Unit&#233; ; Limite basse ; Limite haute ]									
//         [ Hex ]									
//									
//									
//									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_11_____Al_Salam_Bank_Bahrain_20250515 &gt;									
//        &lt; e537dm6ht75up5j50fiHG4DF62r6D7849FtH4Bjn483oUPnz1855404MSz45Yxw8 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000181090929.627096000000000000 ; 000000201064086.828041000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000011452A5132CCA9 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_12_____Almadina_Finance_Investment_20250515 &gt;									
//        &lt; OU4nOtt06jkWQED49M0dcG6956B4jPcEJ2x43x92Co2Qp8pW9nGl2u9lp4n74cK6 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000201064086.828041000000000000 ; 000000219910587.516598000000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000132CCA914F8E93 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_13_____Al_Salam_Group_Holding_20250515 &gt;									
//        &lt; BY8PEgOv1UQ6Teki5YPdJDKf7F9Yk1rn78nu9bm3l76BWf9O1P14IZiuIDy3BH1e &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000219910587.516598000000000000 ; 000000236706596.542813000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000014F8E931692F84 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_14_____Dubai_Financial_Market_20250515 &gt;									
//        &lt; T968NPS1C52qHjnoks2cgu5T82JvBdmJ9iv59M03ljLrjhD949FIkK5bn4JUx45Z &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000236706596.542813000000000000 ; 000000254619021.069807000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000001692F84184848E &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_15_____Dubai_Investments_20250515 &gt;									
//        &lt; y98l8JWQt5meyoO8uvoxG8P21NTlDQzw7KwDlEET1mk71z6EAFR2k4i2lg6ZYH87 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000254619021.069807000000000000 ; 000000273019373.496874000000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000184848E1A09831 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_16_____Ekttitab_Holding_Company_KSCC_20250515 &gt;									
//        &lt; b0gBCj7fPwYW8P9YX17718TJ3ZJOBcEB54mQyoB3x7VBe6GPMXLcYl66hllWh182 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000273019373.496874000000000000 ; 000000289417875.000936000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000001A098311B99DDC &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_17_____Gulf_General_Investments_Company_20250515 &gt;									
//        &lt; 0KZvniv9PPb0Ssq313EY3Fl02Sp97ZM7QiR43l72LL8Q4725pKAyMG4BFMYJq9eJ &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000289417875.000936000000000000 ; 000000307179615.891649000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000001B99DDC1D4B80A &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_18_____International_Financial_Advisors_KSCC_20250515 &gt;									
//        &lt; 7Fdt4rv6R3c770d7wRih97F6B5SMmXar7X0w9P0OOg5e896Qs2b92IRgYZ2Enmq7 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000307179615.891649000000000000 ; 000000323823077.061058000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000001D4B80A1EE1D64 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_19_____SHUAA_Capital_20250515 &gt;									
//        &lt; nX1ueI2sEHg871nR4GoT88JKLsJAXtm9g271IxE36479pfEYMUnhi32eflZQR6RQ &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000323823077.061058000000000000 ; 000000340399977.520851000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000001EE1D6420768BE &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_20_____Alliance_Insurance_20250515 &gt;									
//        &lt; 1zR4zmwdqL5Dq2aCp7yNVzZXvN7RW4qu9yotkFzihDx7CfY9x4jrE53B9vSs5yNc &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000340399977.520851000000000000 ; 000000357401143.902088000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000020768BE22159D2 &gt;									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
// Programme d&#39;&#233;mission - Lignes 21 &#224; 30									
//									
//									
//									
//									
//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
//         [ Adresse export&#233;e ]									
//         [ Unit&#233; ; Limite basse ; Limite haute ]									
//         [ Hex ]									
//									
//									
//									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_21_____Dubai_Islamic_Insurance_Reinsurance_Co_20250515 &gt;									
//        &lt; PrKhqhF10vpRzf049wL67Am6uo0Z37Wl5118SAi6bHrth5XYgzAeE314EX4bCsWw &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000357401143.902088000000000000 ; 000000375154906.591838000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000022159D223C70E3 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_22_____Arab_Insurance_Group_20250515 &gt;									
//        &lt; 3cs4xz9Dpe3cOeR6CcKe3wQ18HS09gRJld413lmYw4aTYgQO05ALdER2efllA9kI &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000375154906.591838000000000000 ; 000000392325538.991759000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000023C70E3256A42A &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_23_____Arabian_Scandinavian_Insurance_20250515 &gt;									
//        &lt; 4GhKLfD860Px8NI8kUew56s396WYcVXS4Pa585c06M92TyW5vv5FVn65c0iZde2h &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000392325538.991759000000000000 ; 000000408068775.109931000000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000256A42A26EA9DE &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_24_____Al_Sagr_National_Insurance_Company_20250515 &gt;									
//        &lt; O1dX4914CHG2Nfd566r5Za5Gscdj8gw9RRXC66JH9FxC4dJ42Hujbs0647Anp1o2 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000408068775.109931000000000000 ; 000000427466309.604087000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000026EA9DE28C4307 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_25_____Takaful_House_20250515 &gt;									
//        &lt; Lm1JVFRfj1K3LO7fhKWJEm6T7X8ezrp7sAXfVi1iUE6v2alVDZ8JuX29mM4W1q72 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000427466309.604087000000000000 ; 000000446074474.416661000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000028C43072A8A7D7 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_26_____Dubai_Insurance_Co_20250515 &gt;									
//        &lt; 5Wa1yAG9M1Cfwcu73Eor93uraZ8g0Whhx91m41O7t4gwl3H6U6zY5cGvy4OxRFts &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000446074474.416661000000000000 ; 000000467318875.367803000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000002A8A7D72C91270 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_27_____Dubai_National_Insurance_Reinsurance_20250515 &gt;									
//        &lt; r586jJb8Rq1nU22Hk1nUT5b6p6b2w7xFETi7qbr5TrIHE00PZlfkpekYC6u8XI4p &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000467318875.367803000000000000 ; 000000487222689.531227000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000002C912702E7715D &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_28_____National_General_Insurance_Company_20250515 &gt;									
//        &lt; 9t4hbYXLYQKF9C53D0EUdsgGX4uqP4LoY1WkFI6ah57vPTq78tDt7OS6yGMpmnD7 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000487222689.531227000000000000 ; 000000505364361.034325000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000002E7715D3031FF4 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_29_____Oman_Insurance_Company_20250515 &gt;									
//        &lt; FB57FP6BA63R6A3uIdJWlIZ0wQL74e52n3Dc8fe5lff5Z03Z86x83LFlaJ3m64H0 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000505364361.034325000000000000 ; 000000527065625.946488000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003031FF43243D03 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_30_____ORIENT_Insurance_20250515 &gt;									
//        &lt; CRrto07e68fb6me4G2Z77AB7cbxfocb1nTe6b3IdY4A9oviFwLB8c8874N0WsfSS &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000527065625.946488000000000000 ; 000000547998796.510605000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003243D033442E08 &gt;									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
// Programme d&#39;&#233;mission - Lignes 31 &#224; 40									
//									
//									
//									
//									
//     [ Nom du portefeuille ; Num&#233;ro de la ligne ; Nom de la ligne ; Ech&#233;ance ]									
//         [ Adresse export&#233;e ]									
//         [ Unit&#233; ; Limite basse ; Limite haute ]									
//         [ Hex ]									
//									
//									
//									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_31_____Islamic_Arab_Insurance_Company_20250515 &gt;									
//        &lt; 2UKS2SWt3pF4O3Q76FfQ66j9W5oYCDdc2Vqv98HQJOljS85738bfN3Os336p50ju &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000547998796.510605000000000000 ; 000000566661310.057538000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003442E08360A813 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_32_____Takaful_Emarat_20250515 &gt;									
//        &lt; n9k2H50Pwn0TGM942712tmMM2eyj5WG4b0m3297Wq4MdLVrU50VHt6C1Eh0zH430 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000566661310.057538000000000000 ; 000000583724083.698779000000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000360A81337AB138 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_33_____Arabtec_Holding_20250515 &gt;									
//        &lt; O88c2zVDlgCdQJKj8v1L87nGL9E795ftS08YD9ACJbl2k81cD25q59LZ7V365424 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000583724083.698779000000000000 ; 000000605437993.596515000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000037AB13839BD337 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_34_____Dubai_Development_Company_20250515 &gt;									
//        &lt; tVDvGTqz8vqY1Z93c1071erwxHExZ549rQ0sEZqQ133X3kHN5n45PCSPIk14OZWr &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000605437993.596515000000000000 ; 000000622248632.363165000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000039BD3373B579DF &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_35_____Deyaar_Development_20250515 &gt;									
//        &lt; nmd29bX25ZMW54v5HqQh91G5yQ2Q049iJYYpakj561Vs3k9MFJ309b4tNq5j82c1 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000622248632.363165000000000000 ; 000000642389976.238936000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003B579DF3D43596 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_36_____Drake_Scull_International_20250515 &gt;									
//        &lt; Cm502Spxr8UliMS2sJCHmZMiI817V82da3fHZ6Tcdbo2JJq164E6YZE549eXy7me &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000642389976.238936000000000000 ; 000000663059955.883481000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003D435963F3BFCC &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_37_____Emaar_Properties_20250515 &gt;									
//        &lt; d01DpppPcKcoWJp8x9eY13H0Rz3NNfg8oVkTKYYEm3xT99QVT9gR4YzP8wSKkzjW &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000663059955.883481000000000000 ; 000000680245417.088088000000000000 ] &gt;									
//        &lt; 0x000000000000000000000000000000000000000000000000003F3BFCC40DF8DE &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_38_____EMAAR_MALLS_GROUP_20250515 &gt;									
//        &lt; 3JV88Hh40Mmxy6V26cLlWVw3A0f27vx88ojqeNg50Dl6ZdG55DL5TPN5m8mb9yj7 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000680245417.088088000000000000 ; 000000695833300.726203000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000040DF8DE425C1E2 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_39_____Al_Mazaya_Holding_Company_20250515 &gt;									
//        &lt; 9AEgr4t3ISQ3qHw7ptdL9B5849DjHi18m95A0a3z60ecZ46VZr0U71xZHojtoava &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000695833300.726203000000000000 ; 000000711411867.403057000000000000 ] &gt;									
//        &lt; 0x00000000000000000000000000000000000000000000000000425C1E243D8743 &gt;									
//     &lt; DUBAI_Portfolio_Ib_metadata_line_40_____Union_Properties_20250515 &gt;									
//        &lt; hn6AbgKsZfCC6rfdMeV9Zifc3NEOUSe6yMy9S18fTXQQT8hk3RFAusn917sbFI65 &gt;									
//        &lt;  u ==&quot;0.000000000000000001&quot; : ] 000000711411867.403057000000000000 ; 000000728002043.355369000000000000 ] &gt;									
//        &lt; 0x0000000000000000000000000000000000000000000000000043D8743456D7CC &gt;									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
}