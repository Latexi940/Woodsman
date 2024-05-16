using Godot;
using System;

public partial class player : CharacterBody3D
{
	[Export]
	public float Speed = 15.0f;
	[Export]
	public float AxeDamage = 3;
	[Export]
	public float Sensitivity = 300f;

	private float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();
	private AnimationPlayer animationPlayer;
	private AnimationTree animationTree;
	private Node3D cameraPivot;
	private Area3D AxeArea;
	private bool isAttacking = false;
	private bool hasHit = false;

	float attack1_val = 0;
	float attack2_val = 0;
	float run_val = 0;
	enum Anim{
		IDLE,
		ATTACK1,
		ATTACK2,
		RUN
	}
	
	Anim CurrentAnim = Anim.IDLE;
	float blendSpeed = 15;

	public override void _Ready()
	{
		Node barbarianNode = GetNode("BarbarianModel");
		animationPlayer = barbarianNode.GetNode<AnimationPlayer>("AnimationPlayer");
		animationTree = barbarianNode.GetNode<AnimationTree>("AnimationTree");
		animationTree.AnimationStarted += AnimStarted;
		animationTree.AnimationFinished += AnimFinished;
		cameraPivot = GetNode<Node3D>("CameraPivot");
		Input.MouseMode = Input.MouseModeEnum.Captured;
		AxeArea = barbarianNode.GetNode<Area3D>("Rig/Skeleton3D/1H_Axe/AxeArea3D");
		AxeArea.BodyEntered += BodyEnteredOnAxe;
	}

	public override void _PhysicsProcess(double delta)
	{
		
		Vector3 velocity = Velocity;
		
		Vector2 inputDir = Input.GetVector("left", "right", "forward", "back");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Speed;
			velocity.Z = direction.Z * Speed;
			CurrentAnim = Anim.RUN;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
			if(!isAttacking){
				CurrentAnim = Anim.IDLE;
			}
		}

		Velocity = velocity;
		MoveAndSlide();
		HandleAnims(delta);
	}
	
	public override void _Input(InputEvent @event)
	{
		if(@event is InputEventMouseMotion mouseMotion){
			RotateY(mouseMotion.Relative.X / Sensitivity);

			cameraPivot.RotateX(mouseMotion.Relative.Y / Sensitivity);
			
			float clamped = Mathf.Clamp(cameraPivot.Rotation.X, -1.2f, 0.2f);
			cameraPivot.Rotation = new Vector3(clamped, cameraPivot.Rotation.Y, cameraPivot.Rotation.Z);
		}
		
		if(@event is InputEventMouseButton mouseClick){
			if (@event.IsActionPressed("main_action")){
				CurrentAnim = Anim.ATTACK1;
				isAttacking = true;
				hasHit = false;
			}
			if (@event.IsActionReleased("main_action")){
				CurrentAnim = Anim.IDLE;
				isAttacking = false;
			}
			
			if (@event.IsActionPressed("secondary_action")){
				CurrentAnim = Anim.ATTACK2;
				isAttacking = true;
				hasHit = false;
			}
			if (@event.IsActionReleased("secondary_action")){
				CurrentAnim = Anim.IDLE;
				isAttacking = false;
			}
		}
	}
	
	public void BodyEnteredOnAxe(Node3D body){
		if(isAttacking && !hasHit && body.IsInGroup("Tree")){
			body.Call("get_hit", AxeDamage);
			hasHit = true;
		}
	}
	
	public void AnimFinished(StringName anim){
		GD.Print("Finished " + anim);
	}
	
	public void AnimStarted(StringName anim){
		GD.Print("Started " + anim);
	}
	
	private void UpdateTree(){
		animationTree.Set("parameters/Attack1/blend_amount", attack1_val);
		animationTree.Set("parameters/Attack2/blend_amount", attack2_val);
		animationTree.Set("parameters/Run/blend_amount", run_val);
	}
	
	private void HandleAnims(double delta){
		float animSpeed = Convert.ToSingle(blendSpeed * delta);
		
		switch (CurrentAnim){
			case Anim.IDLE:
				run_val = Mathf.Lerp(run_val, 0, animSpeed);
				attack1_val = Mathf.Lerp(attack1_val, 0, animSpeed);
				attack2_val = Mathf.Lerp(attack2_val, 0, animSpeed);
				break;
			case Anim.RUN:
				run_val = Mathf.Lerp(run_val, 1, animSpeed);
				attack1_val = Mathf.Lerp(attack1_val, 0, animSpeed);
				attack2_val = Mathf.Lerp(attack2_val, 0, animSpeed);
				break;
			case Anim.ATTACK1:
				run_val = Mathf.Lerp(run_val, 0, animSpeed);
				attack1_val = Mathf.Lerp(attack1_val, 1, animSpeed);
				attack2_val = Mathf.Lerp(attack2_val, 0, animSpeed);
				break;
			case Anim.ATTACK2:
				run_val = Mathf.Lerp(run_val, 0, animSpeed);
				attack1_val = Mathf.Lerp(attack1_val, 0, animSpeed);
				attack2_val = Mathf.Lerp(attack2_val, 1, animSpeed);
				break;
		}
		
		UpdateTree();
	}
	
}
