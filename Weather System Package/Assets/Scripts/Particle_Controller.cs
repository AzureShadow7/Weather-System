using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class Particle_Controller : MonoBehaviour
{
    public ParticleSystem rain;
    ParticleSystem.MainModule main;
    public Camera cam;
    public GameObject player;

    public enum rainIntensity
    {
        light,
        heavy
    }

    public rainIntensity intensity;

    // Start is called before the first frame update
    void Start()
    {
        rain = GetComponent<ParticleSystem>();
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

        var rainEmRate = rain.emission;
        switch(intensity)
        {
            case rainIntensity.light:
                rainEmRate.rateOverTime = 10;
                break;

            case rainIntensity.heavy:
                rainEmRate.rateOverTime = 100;
                break;
        }

    }

}
