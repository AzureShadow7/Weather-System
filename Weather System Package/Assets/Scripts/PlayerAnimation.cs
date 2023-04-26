using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimation : MonoBehaviour
{
    Animator animator;

    bool isWalking;
    
    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        isWalking = animator.GetBool("isWalking");

        if (Input.GetKeyDown(KeyCode.W) && !isWalking)
        {
            animator.SetBool("isWalking", true);
        }

        if (Input.GetKeyUp(KeyCode.W) && isWalking)
        {
            animator.SetBool("isWalking", false);
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            gameObject.transform.position = new Vector3(-121.0f, 0.01f, -97.6f);
        }
    }
}
