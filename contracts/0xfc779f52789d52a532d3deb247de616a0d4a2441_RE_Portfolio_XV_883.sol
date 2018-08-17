pragma solidity 		^0.4.21	;						
										
	contract	RE_Portfolio_XV_883				{				
										
		mapping (address =&gt; uint256) public balanceOf;								
										
		string	public		name =	&quot;	RE_Portfolio_XV_883		&quot;	;
		string	public		symbol =	&quot;	RE883XV		&quot;	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1350709237915270000000000000					;	
										
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
//	}									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; RE_Portfolio_XV_metadata_line_1_____Odyssey_Reinsurance_Company_Am_A_20250515 &gt;									
	//        &lt; 342MsJd9BY87Vs2VkTdNIBv6OgDHA3qhoF9xc9pQNvgH7lJz7HZ433Z72588Ukf8 &gt;									
	//        &lt; 1E-018 limites [ 1E-018 ; 46084375,177347 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000000000000112AF2F01 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_2_____OJSC_INSURANCE_COMPANY_OF_GAZ_INDUSTRY_SOGAZ_Bpp_20250515 &gt;									
	//        &lt; TuNFST6Jrjb57jy7Y41dDpZ3BGKfH884NDx6pe90xd4GV7Q96YlOJb5s0Ttm362P &gt;									
	//        &lt; 1E-018 limites [ 46084375,177347 ; 95545612,671014 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000112AF2F012397F0AE7 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_3_____Oman_A_Oman_Reinsurance_Co_m_m_20250515 &gt;									
	//        &lt; bZX9vp15O5S6uyH1096WoTb9CRxe3OHbDVUDnq8FYv4EE98c2QHR11Ldk6B044FZ &gt;									
	//        &lt; 1E-018 limites [ 95545612,671014 ; 108173857,245528 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000002397F0AE7284C436F0 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_4_____Oman_Insurance_Company_PSC_Am_A_20250515 &gt;									
	//        &lt; o8mB5h5vH12Ke8zsBN3QpRSDaFw69N2FAMo5aA1jDk5shJCb2Hu9u97lNFRyRSVO &gt;									
	//        &lt; 1E-018 limites [ 108173857,245528 ; 127454227,24716 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000284C436F02F7AFB978 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_5_____Omnium_Reinsurance_Co_20250515 &gt;									
	//        &lt; kfVIfGplBzrZ3F02jTSxtu8FIDGHz7Oid37d7En2h3R0KxHRyRUxvXM5XzR1Rydg &gt;									
	//        &lt; 1E-018 limites [ 127454227,24716 ; 175503708,90955 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000002F7AFB978416156A3E &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_6_____Omnium_Reinsurance_Co_SA_Ap_20250515 &gt;									
	//        &lt; MUXSQAWjvCCg2DUY1cXIRbHmi353ecqnJ8fC95Zwj3jG29N3r48n2E9S13VMCp47 &gt;									
	//        &lt; 1E-018 limites [ 175503708,90955 ; 235362949,111934 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000416156A3E57ADF5DF3 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_7_____Optimum_Reinsurance_Company_20250515 &gt;									
	//        &lt; 4bL39WZDm9u7zcNl3a35fKV6Hobptp1tiRgQA3P33cT9yIqNPekGXl7RWAYA3eMN &gt;									
	//        &lt; 1E-018 limites [ 235362949,111934 ; 252608961,057728 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000057ADF5DF35E1AAB15D &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_8_____Orient_Insurance_PJSC_A_A_20250515 &gt;									
	//        &lt; 5hgI2IdEnbtgICY49u32be2YQ07hcBd55ox2NCon5Xtzx4r28aB84vWMAp497nuE &gt;									
	//        &lt; 1E-018 limites [ 252608961,057728 ; 300168226,004988 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000005E1AAB15D6FD245F3C &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_9_____Oriental_Insurance_and_Reinsurance_20250515 &gt;									
	//        &lt; uCW0s3KSR8Bn8pz282x7zu3bObQm210C8iw6ha4RT0mI1iOsF5hXW51n3G4rWvpU &gt;									
	//        &lt; 1E-018 limites [ 300168226,004988 ; 329544840,823364 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000006FD245F3C7AC3D8766 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_10_____Overseas_Partners_Limited_20250515 &gt;									
	//        &lt; m36vLM3kBCegv6yM9T3eBDXWOo2GsZs062oeXN09ZBQSHR954T2U1j5pPb2hRN77 &gt;									
	//        &lt; 1E-018 limites [ 329544840,823364 ; 358379439,38619 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000007AC3D87668581BA276 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; RE_Portfolio_XV_metadata_line_11_____Pacific_LifeCorp_20250515 &gt;									
	//        &lt; WjgwSZIo8l3H73FETr1sFnqg8p2II28D72T0v3dAe0Qj80R4b35ELeoJv5z80pm3 &gt;									
	//        &lt; 1E-018 limites [ 358379439,38619 ; 384780653,396014 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000008581BA2768F578B0AF &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_12_____PACRE_AB_20250515 &gt;									
	//        &lt; 50reG8eQGIPfbKUeUYJR8g3o228Kqa049dADf5Z4lp3883E2bkz8s15H09e80zf5 &gt;									
	//        &lt; 1E-018 limites [ 384780653,396014 ; 406647887,37271 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000008F578B0AF977CF70F5 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_13_____Panama_BBB_Barents_Reinsurance_Am_20250515 &gt;									
	//        &lt; zPg99slKuA8E75JfUS2v53b4FFKaXr5OCTnvSEMa098F53JJJ2TpGjFuE05V5Y3j &gt;									
	//        &lt; 1E-018 limites [ 406647887,37271 ; 446419362,72082 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000977CF70F5A64DDE584 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_14_____Paris_Re_20250515 &gt;									
	//        &lt; cD4Du5BKZgJUDEiqccxK1p5W08LluAm9Mr8qNLakSXDXJyq0Wvph1j1NMhU6Dzkj &gt;									
	//        &lt; 1E-018 limites [ 446419362,72082 ; 457005135,789622 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000A64DDE584AA3F6811E &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_15_____Paris_Re_20250515 &gt;									
	//        &lt; Y8V07i4Iu435W56SJD6B2Z4KkUKXiTo24hHh6bBXS7W7Q7O9K5bqc9C1Oyol1d7p &gt;									
	//        &lt; 1E-018 limites [ 457005135,789622 ; 523885012,11154 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000AA3F6811EC329918CF &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_16_____Partner_Re_Limited_20250515 &gt;									
	//        &lt; Pc75yI7j8AwxBUn8z09S572n49CLB0uPWvM6qZZZDN6RWVI4GN5WjRjr82n6N5H3 &gt;									
	//        &lt; 1E-018 limites [ 523885012,11154 ; 537324242,912967 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000C329918CFC82B3BC57 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_17_____Partner_Re_Limited_20250515 &gt;									
	//        &lt; 7m6n01H7nvrwlUX61vbdgkr33f55KWIqhHwN130061uugZp96x1v7gp3hnMpFNN0 &gt;									
	//        &lt; 1E-018 limites [ 537324242,912967 ; 551023930,400859 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000C82B3BC57CD45BCCC4 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_18_____Partner_Re_Services_20250515 &gt;									
	//        &lt; fg68H6k53JdpmNx704YE4JJ14NvJw73x5f36vb031419jhihMQ4u5i5hG16RygI1 &gt;									
	//        &lt; 1E-018 limites [ 551023930,400859 ; 565728715,753078 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000CD45BCCC4D2C01858B &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_19_____Partner_Reinsurance_Co_Limited_Ap_A_20250515 &gt;									
	//        &lt; 1mwN0kCgXu6lHBUe7EBj8hVJixltcJgZ0RGhql6p9J063uvIJ0A45u8V6e6dSqNQ &gt;									
	//        &lt; 1E-018 limites [ 565728715,753078 ; 590266733,615009 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000D2C01858BDBE4390C5 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_20_____partner_reinsurance_company_Limited_Ap_20250515 &gt;									
	//        &lt; Qh1mVDUeySdV7Qe60stA5TDRU40lbO5Q7b8547794gpjmXLu09xeuCXC566sUOP2 &gt;									
	//        &lt; 1E-018 limites [ 590266733,615009 ; 606495147,827913 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000DBE4390C5E1EFE2912 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; RE_Portfolio_XV_metadata_line_21_____PartnerRe_Limited_20250515 &gt;									
	//        &lt; oseiT5kQ6dq3R7HS379Bm771koQ7c0aM1Anm67y6QZ33957ftDrVWOxA2O1C5dIP &gt;									
	//        &lt; 1E-018 limites [ 606495147,827913 ; 621285303,715882 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000E1EFE2912E772625B7 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_22_____Peak_Reinsurance_Company_20250515 &gt;									
	//        &lt; zm4ok5G2VUB435bd5k0BP7KP0Oi75UY9V3oooQ5HD0J7C5F6885b641YN6o87x0B &gt;									
	//        &lt; 1E-018 limites [ 621285303,715882 ; 697308544,052076 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000E772625B7103C4867F9 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_23_____Peak_Reinsurance_Company_Limited__Peak_Re__Am_20250515 &gt;									
	//        &lt; g3wSkrIWRnWc6099VG173I52i7gk59zlQ04ebusYeScTXhHMRUh5fp9X3D1zIWew &gt;									
	//        &lt; 1E-018 limites [ 697308544,052076 ; 732529226,758741 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000103C4867F9110E36E727 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_24_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; bwH70O2B2MXZpch1WR34PeN0fHBH0Ea8AkNs6gcF8ZyAn1D6lu14YlH4ygyd77Yx &gt;									
	//        &lt; 1E-018 limites [ 732529226,758741 ; 811292196,732394 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000110E36E72712E3ADA84D &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_25_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; GsyvsW26a1Y6t3YLyAqd32PZnsawddNjjDSx5ga5cN2M3OJM3c3TBo0O9OXcMSTg &gt;									
	//        &lt; 1E-018 limites [ 811292196,732394 ; 886236796,761977 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000012E3ADA84D14A2620AB0 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_26_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; UF1d4807S9eVJNI8AiEUxnNnfbrz6pR2R37I1cnLmdZn7w7wuPAYuvoZh39N37e1 &gt;									
	//        &lt; 1E-018 limites [ 886236796,761977 ; 904319281,796364 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000014A2620AB0150E29B967 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_27_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; XV9bL5W6w96O4rp3zdORR4UC3sR0nQ9P4iTw2aih0Ke906BJLWiUyXaCXzTpl7w4 &gt;									
	//        &lt; 1E-018 limites [ 904319281,796364 ; 980830244,554802 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000150E29B96716D634303B &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_28_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; JB85i74Buf8s36I29Qu8R97Yim6D14vY299g54DCQ1t6RUv5414g98F66Of9z8HK &gt;									
	//        &lt; 1E-018 limites [ 980830244,554802 ; 1026640384,27562 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000016D634303B17E740EA0F &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_29_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; H71V5A4quEp2790kPxoLYpM78I5Jwf3vzI375m0M7g66DCDGJMnDt9bdf8g2HxAB &gt;									
	//        &lt; 1E-018 limites [ 1026640384,27562 ; 1078613883,31291 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000017E740EA0F191D0A2E1F &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_30_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; EYnR7oGr76Sl9FZ7o4e4yqUKQ61C60H24r4BfbMJ5gsVYQIVu05wyi0C0260JW7X &gt;									
	//        &lt; 1E-018 limites [ 1078613883,31291 ; 1132591625,57541 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000191D0A2E1F1A5EC5ADB1 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; RE_Portfolio_XV_metadata_line_31_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; H7rL8jdXqzJB2psuZOQ6RUg71Kt2351VkL0IF7z4l08PmK4RRBYrS6St22gc0Pzu &gt;									
	//        &lt; 1E-018 limites [ 1132591625,57541 ; 1189242854,37023 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001A5EC5ADB11BB07097F1 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_32_____Pembroke_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; 17jKWfdEU4j1Qc74Wwm3ijXKQL908fXTL8L500JFD3Hoe57rhBkIOxFEEz4SPUqS &gt;									
	//        &lt; 1E-018 limites [ 1189242854,37023 ; 1201920241,16011 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001BB07097F11BFC00C028 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_33_____Pembroke_Managing_Agency_Limited&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;_20250515 &gt;									
	//        &lt; k5h37rYWg5A6M00DjZe94c98Uo5pWOtpfy5XPzhs6Xh9c5l9TgNTCZGj7hI65dt8 &gt;									
	//        &lt; 1E-018 limites [ 1201920241,16011 ; 1213323527,15815 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001BFC00C0281C3FF8C8BF &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_34_____Ping_An_Property_&amp;_Casualty_Insurance_Co_of_China_Limited_Am_20250515 &gt;									
	//        &lt; ZmrE5z9vfn1m3PK70u09PjnDLFm4Y37VabpFzvOWwrgpb227ao1WNiFPLH1X42na &gt;									
	//        &lt; 1E-018 limites [ 1213323527,15815 ; 1232791090,83204 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001C3FF8C8BF1CB401EDCF &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_35_____Platinum_Underwriters_Holdings_Limited_20250515 &gt;									
	//        &lt; g2Wf84zg3G31fVIE86I1FbpXOSi4k37r4rZq3Izt8y1t2g92ghWO3E9356W09Vg8 &gt;									
	//        &lt; 1E-018 limites [ 1232791090,83204 ; 1244652056,32338 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001CB401EDCF1CFAB45374 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_36_____Platinum_Underwriters_Holdings_Limited_20250515 &gt;									
	//        &lt; 4011Wy1U85vSZ7lmnTnpFh2Kof7E84GDf161zaOn8SG8t971vIUJUX3MS4zE17M8 &gt;									
	//        &lt; 1E-018 limites [ 1244652056,32338 ;  ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001CFAB453741D48DB4F49 &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_37_____Platinum_Underwriters_Holdings_Limited_20250515 &gt;									
	//        &lt; Ir4UoPbEziw4aiQWH7ojKyDGKlpQsxq2GNE4pbLLt6cbeI07ZuVi2V9gbwoz8ycy &gt;									
	//        &lt; 1E-018 limites [ 1257763833,17499 ; 1298796065,51769 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001D48DB4F491E3D6D870B &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_38_____PMA_Re_Management_Company_20250515 &gt;									
	//        &lt; 6l29nMNmCCZxv4sY87WczaxVqW696wO0gnPEejb07EYobQyedY8EsbhU5E3tS54y &gt;									
	//        &lt; 1E-018 limites [ 1298796065,51769 ; 1313347030,1582 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E3D6D870B1E9428899B &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_39_____Pozavarovalnica_Sava,_dd__Sava_Re__Am_Am_20250515 &gt;									
	//        &lt; OD6II9X00HsmRBBo7R8F4gwBWsZ5uFJfZ3A535L3j3592CmtCCG1O0JhiCOmL3gz &gt;									
	//        &lt; 1E-018 limites [ 1313347030,1582 ; 1324231558,33625 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E9428899B1ED509026D &gt;									
	//     &lt; RE_Portfolio_XV_metadata_line_40_____ProSight_Specialty_Managing_Agency_Limited_20250515 &gt;									
	//        &lt; O6QFc5aMhH4fA5hCg6BBcx521NEKsuy1dd7wF66A1XRSR3XpDM1TW4I4vz61R8en &gt;									
	//        &lt; 1E-018 limites [ 1324231558,33625 ; 1350709237,91527 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001ED509026D1F72DABE03 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}