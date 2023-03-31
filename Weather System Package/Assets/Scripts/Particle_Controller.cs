using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class Particle_Controller : MonoBehaviour
{
    private ParticleSystem weatherParticle;
    //ParticleSystem.MainModule main;
    public Camera cam;
    public GameObject player;

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

    // Start is called before the first frame update
    void Start()
    {
        weatherParticle = GetComponent<ParticleSystem>();
    }

    //Update is called once per frame
    void Update()
    {
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

        var weatherParticleEmRate = weatherParticle.emission;
        var weatherParticleSimSpeed = weatherParticle.main;

        //The parameters should be put into a function
        switch(intensity)
        {
            case weatherParticleIntensity.light:
                weatherParticleEmRate.rateOverTime = 10;
                weatherParticleSimSpeed.simulationSpeed = 1;
                break;

            case weatherParticleIntensity.heavy:
                weatherParticleEmRate.rateOverTime = 100;
                weatherParticleSimSpeed.simulationSpeed = 3;
                break;
        }

    }
}
