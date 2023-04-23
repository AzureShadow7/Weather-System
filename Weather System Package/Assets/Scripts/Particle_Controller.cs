using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

[RequireComponent(typeof(ParticleSystem))]
public class Particle_Controller : MonoBehaviour
{
    private ParticleSystem weatherParticle;
    private ParticleSystemRenderer weatherParticleRenderer;

    MaterialChange groundChange;
    Material_Manager material_Manager;

    public GameObject plane;
    public GameObject matManager;
    //public GameObject building2;

    [SerializeField] Material[] particleMaterial;

    //private AnimationCurve[] snowSize;
    AnimationCurve snowSize;
    AnimationCurve snowSizeMin;
    AnimationCurve snowSizeMax;
    public float constantVal;

    //WETNESS
    [Header("Wet Materials")]
    [SerializeField] Material[] wetnessMaterials;

    [Header("Snow Materials")]
    [SerializeField] Material[] snowyMaterials;

    //Helper variables
    float wetnessRate;
    public float wetnessThreshold; //fully submerged 11.0f, partially 2.83 > x < 11.0f


    public TMP_Dropdown dropdown;

    public enum weatherParticleIntensity
    {
        light,
        heavy
    }

    public enum weatherType
    {
        rain,
        snow
    }

    public weatherParticleIntensity intensity;
    public weatherType weather;

    // Start is called before the first frame update
    void Start()
    {
        weatherParticle = GetComponent<ParticleSystem>();
        weatherParticleRenderer = GetComponent<ParticleSystemRenderer>();
        groundChange = plane.GetComponent<MaterialChange>();
        material_Manager = matManager.GetComponent<Material_Manager>();

        wetnessRate = 0.1f;

        snowSize = new AnimationCurve();
        snowSizeMin = new AnimationCurve();
        snowSizeMax = new AnimationCurve();

        snowSize.AddKey(0.0f, 0.5f);
        snowSize.AddKey(3.0f, 0.45f);
        snowSize.AddKey(6.0f, 1.0f);

        snowSizeMin.AddKey(0.0f, 0.5f);
        snowSizeMax.AddKey(0.0f, 1.0f);

        constantVal = 1.0f;
    }

    public void weatherChange(int index)
    {
        if (index == 0)
        {
            weather = weatherType.rain;
        }

        if (index == 1)
        {
            weather = weatherType.snow;
        }
    }

    public void resetEffects()
    {
        for (int i = 0; i < wetnessMaterials.Length; i++)
        {
            wetnessMaterials[i].SetFloat("_Wetness", 0.0f);
        }

        for (int i = 0; i < snowyMaterials.Length; i++)
        {
            snowyMaterials[i].SetFloat("_Snow_Amount", 0.0f);
        }
    }

    public void weatherIntensityCheck(int level)
    {
        if (level == 0)
        {
            intensity = weatherParticleIntensity.light;
        }

        if (level == 1)
        {
            intensity = weatherParticleIntensity.heavy;
        }
    }

    //Update is called once per frame
    void Update()
    {

        var weatherParticleEmRate = weatherParticle.emission;
        var weatherParticleSimSpeed = weatherParticle.main;

        if (Input.GetKeyUp(KeyCode.Alpha0))
        {
            for(int i = 0; i < wetnessMaterials.Length; i++)
            {
                wetnessMaterials[i].SetFloat("_Wetness", 0.0f);
            }

            for (int i = 0; i < snowyMaterials.Length; i++)
            {
                snowyMaterials[i].SetFloat("_Snow_Amount", 0.0f);
            }
        }


        switch (weather)
        {
            case weatherType.rain:
                groundChange.rainfall();
                material_Manager.rainfall();
                weatherParticleRenderer.material = particleMaterial[0];
                weatherParticleRenderer.renderMode = ParticleSystemRenderMode.Stretch;
                weatherParticleSimSpeed.startSize3D = true;
                weatherParticleSimSpeed.startSizeX = 0.1f;
                weatherParticleSimSpeed.startSizeY = UnityEngine.Random.Range(0.5f, 1.0f);
                break;

            case weatherType.snow:
                groundChange.snowfall();
                material_Manager.snowfall();
                weatherParticleRenderer.material = particleMaterial[1];
                weatherParticleRenderer.renderMode = ParticleSystemRenderMode.Billboard;
                weatherParticleSimSpeed.startSize3D = true;
                weatherParticleSimSpeed.startSizeX = new ParticleSystem.MinMaxCurve(constantVal, snowSizeMin, snowSizeMax);
                weatherParticleSimSpeed.startSizeY = new ParticleSystem.MinMaxCurve(constantVal, snowSizeMin, snowSizeMax);
                break;
        }

        

        //The parameters should be put into a function
        switch(intensity)
        {
            case weatherParticleIntensity.light:
                weatherParticleEmRate.rateOverTime = 10;
                weatherParticleSimSpeed.simulationSpeed = 1;

                if (weather == weatherType.rain)
                {
                    for (int i = 0; i < wetnessMaterials.Length; i++)
                    {
                        float wetnessAmount = wetnessMaterials[i].GetFloat("_Wetness");
                        wetnessAmount = wetnessAmount += 0.009f * Time.deltaTime;//(Time.time / 50.0f) % 1.2f;
                        wetnessMaterials[i].SetFloat("_Wetness", wetnessAmount);
                    }
                    
                }

                if (weather == weatherType.snow)
                {
                    //groundChange.gradualSnowMat.SetFloat("_Snow_Amount", 0.0f);
                    //float snowAmount = (Time.time / 50.0f) % 1.2f;

                    for (int i = 0; i < snowyMaterials.Length; i++)
                    {
                        float snowAmount = snowyMaterials[i].GetFloat("_Snow_Amount");

                        snowAmount = snowAmount + 0.01f * Time.deltaTime;

                        snowyMaterials[i].SetFloat("_Snow_Amount", snowAmount);
                    }

                    if (groundChange.gradualSnowMat.GetFloat("_Snow_Amount") > 1.0f)
                    {
                        groundChange.snowedGround();
                    }
                }

                break;

            case weatherParticleIntensity.heavy:
                weatherParticleEmRate.rateOverTime = 100;
                weatherParticleSimSpeed.simulationSpeed = 3;

                if (weather == weatherType.rain)
                {

                    for(int i = 0; i < wetnessMaterials.Length; i++ )
                    {
                        float wetnessAmount = wetnessMaterials[i].GetFloat("_Wetness");
                        wetnessAmount = wetnessAmount += wetnessRate * Time.deltaTime;//(Time.time / 50.0f) % 1.2f;
                        wetnessMaterials[i].SetFloat("_Wetness", wetnessAmount);

                        if (wetnessMaterials[i].GetFloat("_Wetness") > wetnessThreshold)
                        {
                            wetnessRate = 0.0f;
                        }
                    }
                    
                }

                if (weather == weatherType.snow)
                {
                    for (int i = 0; i < snowyMaterials.Length; i++)
                    {
                        float snowAmount = snowyMaterials[i].GetFloat("_Snow_Amount");

                        snowAmount = snowAmount + 0.05f * Time.deltaTime;

                        snowyMaterials[i].SetFloat("_Snow_Amount", snowAmount);
                    }

                    if (groundChange.gradualSnowMat.GetFloat("_Snow_Amount") > 1.0f)
                    {
                        //groundChange.snowedGround();
                        material_Manager.snowedGround();
                    }
                }

                break;

        }

    }
}
