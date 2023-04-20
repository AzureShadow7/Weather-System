using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundChange : MonoBehaviour
{
    // Start is called before the first frame update

    public Material gradualSnowMat;
    public Material gradualRainMat;
    public Material walkableSnowMat;

    MeshRenderer meshRenderer;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        Material currentMaterial = meshRenderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void snowfall()
    {
        meshRenderer.material = gradualSnowMat;
        //gradualSnowMat.SetFloat("_Snow_Amount", 0.0f);
        //float snowAmount = (Time.time / 50.0f) % 1.2f;
        //gradualSnowMat.SetFloat("_Snow_Amount", snowAmount);

        //if (gradualSnowMat.GetFloat("_Snow_Amount") == 1.0f)
        //{
        //    snowedGround();
        //}
    }

    public void snowedGround()
    {
        meshRenderer.material = walkableSnowMat;
    }

    public void rainfall()
    {
        meshRenderer.material = gradualRainMat;
    }
}
