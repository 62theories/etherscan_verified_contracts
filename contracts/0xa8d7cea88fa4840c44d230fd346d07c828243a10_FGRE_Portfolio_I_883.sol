pragma solidity 		^0.4.21	;						
										
	contract	FGRE_Portfolio_I_883				{				
										
		mapping (address =&gt; uint256) public balanceOf;								
										
		string	public		name =	&quot;	FGRE_Portfolio_I_883		&quot;	;
		string	public		symbol =	&quot;	FGRE883I		&quot;	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1579789427442530000000000000000					;	
										
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
	//     &lt; FGRE_Portfolio_I_metadata_line_1_____Caisse_Centrale_de_Reassurance_20580515 &gt;									
	//        &lt; YUDQk3wcl09JG5imzMAar9iaS2FvL2ziH9c5dl88vkoYU89zP2rR8K9T174WA03Y &gt;									
	//        &lt; 1E-018 limites [ 1E-018 ; 583308360,349711 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000000000000037A0ED4 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_2_____CCR_FGRE_Fonds_de_Garantie_des_Risques_lies_a_l_Epandage_des_Boues_d_Epuration_Urbaines_et_Industrielles_20580515 &gt;									
	//        &lt; 3KnAoRDyNvOU3QdAHz24Fsr2T5sn9X2k0bYK58f2dCc45W2xN8t2L7UFOHUVowmn &gt;									
	//        &lt; 1E-018 limites [ 583308360,349711 ; 14474986111,6764 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000000037A0ED456471373 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_3_____SYDEME_20580515 &gt;									
	//        &lt; ae9c4lfy8FZavqKMr6qOMN8Z8hw9szxRxuToWQyf8Sg3Cz3kWm7Uxrq5VjzYh50t &gt;									
	//        &lt; 1E-018 limites [ 14474986111,6764 ; 116485338032,792 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000000564713732B64E852B &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_4_____REGIE_ECOTRI_MOSELLE_EST_20580515 &gt;									
	//        &lt; iCMccCB5rSSDuVuG3sv6W8T3tUhR1591nCUp9sZi7R1SDGfnLYR5mE18U91qQbB1 &gt;									
	//        &lt; 1E-018 limites [ 116485338032,792 ; 209932995521,122 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000002B64E852B4E34C5460 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_5_____REGIE_CSM_CONFECTION_DES_SACS_MULTI_FLUX_20580515 &gt;									
	//        &lt; m2ZNyF0u7U949W71xRD4kG6lzhCb0cwCNXK85o5P0vGDv71ywZ3iG41bBIkc6kR2 &gt;									
	//        &lt; 1E-018 limites [ 209932995521,122 ; 211516755249,413 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000004E34C54604ECBCF485 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_6_____REGIE_DSM_DISTRIBUTION_DES_SACS_MULTI_FLUX_20580515 &gt;									
	//        &lt; 6B9jOLkxcovb71r03VmOan1jh1ZNdnm83LW2AbGz9gbhYQl6VXZ0EKDa4J5fu70Q &gt;									
	//        &lt; 1E-018 limites [ 211516755249,413 ; 217233497687,824 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000004ECBCF48550ED00309 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_7_____SEM_SYDEME_DEVELOPPEMENT_20580515 &gt;									
	//        &lt; 0weKjfou5o7in70W6kpYO1j5EmM1lTP98FKDx075X1VlKO413q4mYM6sp50LNvBz &gt;									
	//        &lt; 1E-018 limites [ 217233497687,824 ; 347409536125,431 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000050ED00309816B8E20D &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_8_____METHAVOS_SAS_20580515 &gt;									
	//        &lt; hLWzVc3i6jrVK7VcG7xsHH6N9p9f4kB75KgF8v7WplglwKmMc5vyQ6M2XWk4C200 &gt;									
	//        &lt; 1E-018 limites [ 347409536125,431 ; 514961961032,884 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000816B8E20DBFD699807 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_9_____SPIRAL_TRANS_SAS_20580515 &gt;									
	//        &lt; EEw3tE0MUhhID9WJ808VL18h8vs62bly8OB60p7V4F2E8H11zxP3bW20Rd5G6k9N &gt;									
	//        &lt; 1E-018 limites [ 514961961032,884 ; 515530143640,136 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000BFD699807C00CC925C &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_10_____GROUPE_LINGENHELD_SA_20580515 &gt;									
	//        &lt; S3au6E564xtyD00H7h4N3KflaT0Rva82U3gnEE482DvGjlpgijHm90YkfR94wLUV &gt;									
	//        &lt; 1E-018 limites [ 515530143640,136 ; 538733364022,892 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000C00CC925CC8B19E052 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; FGRE_Portfolio_I_metadata_line_11_____SYDEME_OBS_DAO_20580515 &gt;									
	//        &lt; 7316yu1I56G6rcGTWV0IYWXU7U7h7Mz8D9Pal6bJwawwNL8pk9MzZN2w90yGVPcX &gt;									
	//        &lt; 1E-018 limites [ 538733364022,892 ; 540501557075,614 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000C8B19E052C95A3ECBC &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_12_____REGIE_ECOTRI_MOSELLE_EST_OBS_DAO_20580515 &gt;									
	//        &lt; InjbgG1SKvS7bHM4wlkDhspVhZYxCn2bRgFGk4SRU587YYpi03L7y90Y1D3GWjkb &gt;									
	//        &lt; 1E-018 limites [ 540501557075,614 ; 543232351839,997 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000C95A3ECBCCA5EAC970 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_13_____REGIE_CSM_CONFECTION_DES_SACS_MULTI_FLUX_OBS_DAO_20580515 &gt;									
	//        &lt; AXUg7FexC2j8Pd6YRv8z38ReZiXzCz33aaW7Eoq8Z41Uptp6Useby4iYecEcZC91 &gt;									
	//        &lt; 1E-018 limites [ 543232351839,997 ; 557612521960,628 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000CA5EAC970CFBA12F64 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_14_____REGIE_DSM_DISTRIBUTION_DES_SACS_MULTI_FLUX_OBS_DAO_20580515 &gt;									
	//        &lt; bg6C5eTONElqCGOWZ6Fj66tAnMhl10FiYhlJS6BD6U2wADwvMNXq8VrUc80WM346 &gt;									
	//        &lt; 1E-018 limites [ 557612521960,628 ; 567334755277,977 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000000CFBA12F64D359422C8 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_15_____SEM_SYDEME_DEVELOPPEMENT_OBS_DAM_20580515 &gt;									
	//        &lt; 267E5tRWxASCKcDOslbWk74Q7lHdqQ9LcQH23j0xwq8XfNKU3rl69l8Xly0yU104 &gt;									
	//        &lt; 1E-018 limites [ 567334755277,977 ; 754508957813,064 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000000D359422C81191394DA5 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_16_____METHAVOS_SAS_OBS_DAC_20580515 &gt;									
	//        &lt; j7HCt0sEKK5N0wr1uc3T3M43E8Fx9oqaiQZ8HCDY4h5Cj0PX0EOd9E13scqT8EL3 &gt;									
	//        &lt; 1E-018 limites [ 754508957813,064 ; 756731561518,271 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001191394DA5119E78BA38 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_17_____SPIRAL_TRANS_SAS_OBS_DAC_20580515 &gt;									
	//        &lt; uBU1p3C5b826j9H2pGi8XmmMFZUPjpHV9vA33H07Hm7LyRh6Wes8Tl9eto6T06c3 &gt;									
	//        &lt; 1E-018 limites [ 756731561518,271 ; 757935845830,361 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000119E78BA3811A5A651C7 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_18_____GROUPE_LINGENHELD_SA_OBS_DAC_20580515 &gt;									
	//        &lt; A3nAM1av1Wgnx569k0au9kdPVLjP5Aaa8BxCh2776L1aS2neSG47q3n77Gk5nCSq &gt;									
	//        &lt; 1E-018 limites [ 757935845830,361 ; 758196128380,951 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000011A5A651C711A7337AA6 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_19_____SAGILOR_SARL_20580515 &gt;									
	//        &lt; 71slAjTF2942Vh35iZ9Jxo9MXJ94aYHK9E4hPi3RJIxfDHJeL2pTh6694PKzzaeP &gt;									
	//        &lt; 1E-018 limites [ 758196128380,951 ; 758338985697,514 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000011A7337AA611A80D764A &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_20_____SAGILOR_SARL_OBS_DAC_20580515 &gt;									
	//        &lt; qvP5169oWl81FGIg7u1HGCORI0Z87zlU4mSvVAKvhE15Q7720BkFh7g46kLAyv42 &gt;									
	//        &lt; 1E-018 limites [ 758338985697,514 ; 758645306252,734 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000011A80D764A11A9E0DEC1 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; FGRE_Portfolio_I_metadata_line_21_____CCR_FGRE_IDX_SYDEME_20580515 &gt;									
	//        &lt; A5sC9ZEFtA2yA8X0vfi3b6165rpOnG7vKYIy83LOGRjLCv26279bNej0kbTPFPDp &gt;									
	//        &lt; 1E-018 limites [ 758645306252,734 ; 825398527634,891 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000011A9E0DEC11337C233DB &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_22_____CCR_FGRE_IDX_REGIE_ECOTRI_MOSELLE_EST_20580515 &gt;									
	//        &lt; B8Bj5D75Fk7u0j2cb88IWAbCG6Lf8GUzP4v0vqD52ja34Igf748ePEtLDj2350l5 &gt;									
	//        &lt; 1E-018 limites [ 825398527634,891 ; 987183990485,361 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001337C233DB16FC133A49 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_23_____CCR_FGRE_IDX_REGIE_CSM_CONFECTION_DES_SACS_MULTI_FLUX_20580515 &gt;									
	//        &lt; 9bz3xtA0z6rY2D9NpnldS4RsZ9Lv64g8UV3h45N6PQ7V0g55l9443O49z9e5IWmX &gt;									
	//        &lt; 1E-018 limites [ 987183990485,361 ; 987323943581,669 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000016FC133A4916FCE8C776 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_24_____CCR_FGRE_IDX_REGIE_DSM_DISTRIBUTION_DES_SACS_MULTI_FLUX_20580515 &gt;									
	//        &lt; 74sM8JazkSLqowDd8sEknEj510pnZNNnVIpgJ6XK39k5e4rHBc9Opj5uPKElpSaN &gt;									
	//        &lt; 1E-018 limites [ 987323943581,669 ; 987556222640,921 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000016FCE8C77616FE4B3578 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_25_____CCR_FGRE_IDX_SEM_SYDEME_DEVELOPPEMENT_20580515 &gt;									
	//        &lt; 0O78pcYigL75snN3u016Pl48sX55gqaTQg5HNO36W1zlJxB2X1Flsbn0zOvgcT1g &gt;									
	//        &lt; 1E-018 limites [ 987556222640,921 ; 989401898343,835 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000016FE4B357817094B7C8A &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_26_____CCR_FGRE_IDX_METHAVOS_SAS_20580515 &gt;									
	//        &lt; lo6gVeyQZ5dgodhOa9wF8Xve9to4LJ1JrQ2KF1XX7sPBV8Myio176sL97DN0hP1M &gt;									
	//        &lt; 1E-018 limites [ 989401898343,835 ; 989624923072,177 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000017094B7C8A170A9FCB93 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_27_____CCR_FGRE_IDX_SPIRAL_TRANS_SAS_20580515 &gt;									
	//        &lt; i00oRb2v67686W4Oxrtobl39RtpERLm78HJ4aokF46idHvPpY8O548vhBcKWzG43 &gt;									
	//        &lt; 1E-018 limites [ 989624923072,177 ; 990548711561,624 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000170A9FCB931710216274 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_28_____CCR_FGRE_IDX_GROUPE_LINGENHELD_SA_20580515 &gt;									
	//        &lt; 3Vu28fIPS64W1lVs02q8PYKowcZ5AUA07RN6rWhgmBBrnE78h4xnC27HPvIx579Y &gt;									
	//        &lt; 1E-018 limites [ 990548711561,624 ; 990670347370,608 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000017102162741710DAFC71 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_29_____CCR_FGRE_IDX_SAGILOR_SARL_20580515 &gt;									
	//        &lt; 1Z8CF5B65D7WP5D5reszn9o64tXC65DSq8HaL3xN09A8SF4daQuMWS4DpY49v1H4 &gt;									
	//        &lt; 1E-018 limites [ 990670347370,608 ; 993103443723,149 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001710DAFC71171F5B98B4 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_30_____SOCIETE_DU_NOUVEAU_PORT_DE_METZ_20580515 &gt;									
	//        &lt; Trw0tlfPepnte2du5k22e0rm94BGLohz4rpg3a46kFgpusmAdel2w5DM3ba90xp7 &gt;									
	//        &lt; 1E-018 limites [ 993103443723,149 ; 1165500246040,28 ] &gt;									
	//        &lt; 0x00000000000000000000000000000000000000000000171F5B98B41B22EC3D9C &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     &lt; FGRE_Portfolio_I_metadata_line_31_____Fonds_de_garantie_des_risques_lies_a_l_epandage_des_boues_issues_de_l_industre_de_methanisation_20580515 &gt;									
	//        &lt; s1D0h1pdtqF7h3C85KJo4QYDMkVN0Ff7zv7HLHhTh3IzY0jcXzfXuvx26UyL93Vx &gt;									
	//        &lt; 1E-018 limites [ 1165500246040,28 ; 1290704803866,65 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001B22EC3D9C1E0D333C03 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_32_____SHS_Soci&#233;te_Holding_du_Syndicat_DMME_soci&#233;te_de_gestion_du_fonds_de_garantie_des_risques_lies_a_la_epandage_des_boues_issues_de_l_industrie_de_methanisation_20580515 &gt;									
	//        &lt; S4dwaEQBX7J515883oyQ7L90qCcIn7vj125639gWR33mO72eIJ166Kqp0xWRQGXm &gt;									
	//        &lt; 1E-018 limites [ 1290704803866,65 ; 1295403858538,79 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E0D333C031E29356C3E &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_33_____SFS_Soci&#233;te_Financiere_du_Syndicat_DMME_societe_de_gestion_des_cotisations_et_provisions_pour_l&#39;indemnisation_des_exploitants_agricoles_sylvicoles_et_forestiers_20580515 &gt;									
	//        &lt; N2fUc2Tn9184W8qE0OeT6SLLDT4Qk956rNxoO71SzL671Qxcehr6z47HrFwRHfg3 &gt;									
	//        &lt; 1E-018 limites [ 1295403858538,79 ; 1295551014450,21 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E29356C3E1E2A15F705 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_34_____GRDF_20580515 &gt;									
	//        &lt; 0TZhJCc9aZL638b40FdWi6Fa7x37m0M32xBwDy5TJW3y3dErlP8E923zgQ2jgxi7 &gt;									
	//        &lt; 1E-018 limites [ 1295551014450,21 ; 1297855872414,5 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E2A15F7051E37D2E629 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_35_____METHAVALOR_20580515 &gt;									
	//        &lt; 95Io3eoe8fjFCr0g4r6u9g6NK04uD16HmZDQy6P7pk7zLZ2YjB19A6LPNFzsW8JI &gt;									
	//        &lt; 1E-018 limites [ 1297855872414,5 ; 1457761232536,92 ] &gt;									
	//        &lt; 0x000000000000000000000000000000000000000000001E37D2E62921F0EF1D76 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_36_____LEGRAS_20580515 &gt;									
	//        &lt; 8y25S9831k844lYjQ009718yQR0L9knIOV32LzR972iEEHPwmHZlxmmJEC07424O &gt;									
	//        &lt; 1E-018 limites [ 1457761232536,92 ;  ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000021F0EF1D7623C829D434 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_37_____CCR_FGRE_IDX_GRDF_20580515 &gt;									
	//        &lt; 8op9iKEgfw97VA98QQ2lZ3mIBo52R4tL1G1026rast7kyZGCf1AT5U0g2N1I7AkO &gt;									
	//        &lt; 1E-018 limites [ 1536820398604,73 ; 1537020842150,07 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000023C829D43423C95BAE77 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_38_____CCR_FGRE_IDX_METHAVALOR_20580515 &gt;									
	//        &lt; U8jUWH0M46faUoLC4dk5IA3zYKXw4zOxzRtUBc32IuS3nCz3g5hGbk62ql28pD6r &gt;									
	//        &lt; 1E-018 limites [ 1537020842150,07 ; 1574094200080,45 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000023C95BAE7724A65522E8 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_39_____CCR_FGRE_IDX_LEGRAS_20580515 &gt;									
	//        &lt; FB5mewmtfXrafBx6vWbXU81f98wIP6n3vxzY7XJUOHhUXeO5b15Dt4V2f6P95cnM &gt;									
	//        &lt; 1E-018 limites [ 1574094200080,45 ; 1578417216092,89 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000024A65522E824C0198909 &gt;									
	//     &lt; FGRE_Portfolio_I_metadata_line_40_____SPIRAL_TRANS_AB_AB_20580515 &gt;									
	//        &lt; QN7lvataPm5A2698jqaB8eRZBfO1lp9CAL1peRlB68iDGz0qc96m44aIm9N5Rh1z &gt;									
	//        &lt; 1E-018 limites [ 1578417216092,89 ; 1579789427442,53 ] &gt;									
	//        &lt; 0x0000000000000000000000000000000000000000000024C019890924C8475D18 &gt;									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}