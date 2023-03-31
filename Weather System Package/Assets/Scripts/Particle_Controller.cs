using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class Particle_Controller : MonoBehaviour
{
    private ParticleSystem weatherParticle;
    private ParticleSystemRenderer weatherParticleRenderer;

    [SerializeField] Material[] particleMaterial;

    public Camera cam;
    public GameObject player;

    //private AnimationCurve[] snowSize;
    AnimationCurve snowSize;
    AnimationCurve snowSizeMin;
    AnimationCurve snowSizeMax;
    public float constantVal;

    //WETNESS
    [SerializeField] private Material wetnessMat;

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

        //snowSize = new AnimationCurve[2];

        //snowSize[0] = new AnimationCurve();
        //snowSize[0].AddKey(0.0f, 0.5f);
        //snowSize[0].AddKey(3.0f, 0.45f);
        //snowSize[0].AddKey(6.0f, 1.0f);

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

    //Update is called once per frame
    void Update()
    {
        var weatherParticleEmRate = weatherParticle.emission;
        var weatherParticleSimSpeed = weatherParticle.main;

        //float camToPlayerDist;

        //camToPlayerDist = Vector3.Distance(cam.transform.position, player.transform.position);

        //if (camToPlayerDist < 20.0f) //closer to camera is more particles
        //{
        //    main.maxParticles = 1000;
        //}
        //else
        //{
        //    main.maxParticles = 10;
        //}

        //if (Input.GetKey(KeyCode.D))
        //{
        //    Debug.Log("Distance is: " + camToPlayerDist);
        //}

        switch (weather)
        {
            case weatherType.rain:
                weatherParticleRenderer.material = particleMaterial[0];
                weatherParticleRenderer.renderMode = ParticleSystemRenderMode.Stretch;
                weatherParticleSimSpeed.startSize3D = true;
                weatherParticleSimSpeed.startSizeX = 0.1f;
                weatherParticleSimSpeed.startSizeY = Random.Range(0.5f, 1.0f);
                break;

            case weatherType.snow:
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
                    float wetnessAmount = wetnessMat.GetFloat("_Wetness");
                    wetnessAmount = wetnessAmount += 0.009f * Time.deltaTime;//(Time.time / 50.0f) % 1.2f;
                    wetnessMat.SetFloat("_Wetness", wetnessAmount);
                }

                break;

            case weatherParticleIntensity.heavy:
                weatherParticleEmRate.rateOverTime = 100;
                weatherParticleSimSpeed.simulationSpeed = 3;

                if (weather == weatherType.rain)
                {
                    float wetnessAmount = wetnessMat.GetFloat("_Wetness");
                    wetnessAmount = wetnessAmount += 0.1f * Time.deltaTime;//(Time.time / 50.0f) % 1.2f;
                    wetnessMat.SetFloat("_Wetness", wetnessAmount);
                }

                break;
        }

    }
}
