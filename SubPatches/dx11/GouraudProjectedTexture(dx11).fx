//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 
//material properties
float4 mAmb  : COLOR <String uiname="Ambient Color";>  = {  0.6,    0.6,    0.6,    1.00000  };
float4 mDiff : COLOR <String uiname="Diffuse Color";>  = {  0.7,    0.7,    0.7,    1.00000  };
float4 mSpec : COLOR <String uiname="Specular Color";> = {  0.63,   0.63,   0.63,   1.00000  };
float mPower <String uiname="Power"; float uimin=0.0;> = 10.0;   //shininess of specular highlight

//light properties
float4 lAmb  : COLOR <String uiname="Ambient Light";>  = {  0.4,    0.4,   0.4,     1.00000  };
float4 lDiff : COLOR <String uiname="Diffuse Light";>  = {  0.63,   0.63,  0.63,    1.00000  };
float4 lSpec : COLOR <String uiname="Specular Light";> = {  0.46,   0.46,  0.46,    1.00000  };
float3 lDir <string uiname="Light Direction";>  = {   0.577,   -0.577,   0.577  };          //Light Direction ( in view space !! )

//texture
float4x4 tTex <string uiname="Texture Transform";>;     
Texture2D texture2d <string uiname="Texture";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
	
	// transform position to texture coordinate (this is the tricky line)
    output.TexCd = mul( input.PosO, tTex );
	
    //output.TexCd = input.TexCd;
    return output;
}




float4 PS(vs2ps In): SV_Target
{
    In.TexCd.xy = In.TexCd.xyz/In.TexCd.w;
	float4 col = texture2d.Sample(linearSampler,In.TexCd.xy);
	col.xyz = col.xyz * cAmb.xyz;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




