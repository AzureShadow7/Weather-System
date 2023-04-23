using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ground_Customization : MonoBehaviour
{
    [Header("Wetness Shader Properties")]

    [SerializeField] private Material wetfloorMaterial;

    public Texture wetBaseTexture;
    public Texture wetNormalMap;

    [Header("Snow Shader Properties")]

    [SerializeField] private Material snowFloorMaterial;

    public Texture snowBaseTexture;
    public Texture snowNormalMap;


    // Start is called before the first frame update
    void Start()
    {
        wetfloorMaterial.SetTexture("_Albedo", wetBaseTexture);
        wetfloorMaterial.SetTexture("_Normal_Map", wetNormalMap);

        snowFloorMaterial.SetTexture("_Base_Texture", snowBaseTexture);
        snowFloorMaterial.SetTexture("_Base_Normal_Texture", snowNormalMap);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
